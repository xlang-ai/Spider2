"""Decide from the two queries whether a roll-up is *permitted*, then let the data decide.

The data-only check in ``relaxed_compare`` asks whether the finer table
re-aggregates to the coarser one.  That question has a prerequisite it cannot
see: the two results must partition the same base rows, and the measure must
be one that a roll-up can reproduce.  ``COUNT(DISTINCT x)`` summed over parts
overcounts whatever the parts share; a ``HAVING`` clause has already removed
rows from the finer side; a different ``JOIN`` fans rows out.  In each of
those the arithmetic can still come out even, and the data-only check then
reports a grain mismatch for two results that are not the same computation.

This module reads both queries with sqlglot and answers only the
prerequisite.  It never declares two tables equal: a permitted pair still has
to be reproduced row by row from the data.  A refusal carries the reason,
because that list is what says which value needs its additivity authored.

Optional: imported only when sqlglot is installed and the submission carries
SQL.  Without it the comparator behaves exactly as before.
"""
from __future__ import annotations

import re

from sqlglot import exp, parse_one

MAX_UNWRAP_DEPTH = 8


def _arg(node, *names):
    """Fetch an argument under any of its historical keys (``from``/``from_``)."""
    for name in names:
        value = node.args.get(name)
        if value is not None:
            return value
    return None


# A measure that is additive along one axis may not be additive along time:
# month-end balances add up across branches and mean nothing added across
# months.  The fold axis is named by the keys the coarser side dropped, so a
# column name or a column type is what tells us the axis is time.
# A fallback only.  The decision is meant to rest on the values (_looks_like_time
# below), which no wordlist can go stale against; these catch the cases values
# cannot settle, such as a period column spelled Q1/Q2.  English only, because a
# list that reaches for one more natural language and not the rest is arbitrary
# in a way the value test never is.
TIME_HINTS = {"date", "dt", "ym", "yyyymm", "yyyy", "year", "month", "day",
              "time", "period", "quarter", "week"}

ADDITIVE = "ADDITIVE"
SEMI_ADDITIVE = "SEMI_ADDITIVE"
NON_ADDITIVE = "NON_ADDITIVE"


class Refused(Exception):
    """The queries do not permit a roll-up.  Carries the reasons, in order."""

    def __init__(self, reasons):
        super().__init__("; ".join(reasons))
        self.reasons = list(reasons)


def _norm(e, dialect=None):
    """Identity of an expression: the tree, with qualifiers and case folded."""
    if e is None:
        return ""
    e = _unwrap(e)
    sql = e.sql(dialect=dialect, comments=False)
    sql = re.sub(r'"([^"]*)"', r"\1", sql)
    sql = re.sub(r"\b[A-Za-z_][A-Za-z0-9_]*\.", "", sql)
    return re.sub(r"\s+", "", sql).lower()


def _unwrap(e):
    while isinstance(e, (exp.Alias, exp.Paren)):
        e = e.this
    return e


def _column_of(e):
    at = _unwrap(e)
    while isinstance(at, exp.Cast):
        at = _unwrap(at.this)
    return at if isinstance(at, exp.Column) and not isinstance(at.this, exp.Star) else None


def _output_name(e):
    if isinstance(e, exp.Alias):
        return e.alias
    if isinstance(e, exp.Column):
        return e.name
    return None



_DATE_TEXT = re.compile(r"^\s*\d{4}[-/]\d{1,2}([-/]\d{1,2})?\s*$")


def _int_time_encoding(values):
    """The time encoding a column of whole numbers is in, or None.

    Dates are not always text.  A period is routinely carried as 2024, as
    202401, or as 1..12, and a fold over one of those is a fold over time
    exactly as much as a fold over '2024-01-31' is.  Reading only the text
    forms would let a semi-additive measure be summed across time whenever the
    warehouse happened to store the period as a number.

    Erring towards "this is time" costs nothing: a time axis makes a
    semi-additive measure UNDECIDABLE, so a wrong guess here refuses to decide
    rather than deciding wrongly.
    """
    if all(1900 <= v <= 2100 for v in values):
        return "year"
    if all(190001 <= v <= 210012 and 1 <= v % 100 <= 12 for v in values):
        return "yyyymm"
    if all(19000101 <= v <= 21001231 for v in values):
        return "yyyymmdd"
    if all(1 <= v <= 12 for v in values):
        return "month"
    return None


def _looks_like_time(series):
    """True when a column's values read as a period -- the axis is time by type."""
    if str(series.dtype).startswith("datetime"):
        return True
    text, whole, seen = [], [], 0
    for value in series.tolist():
        if value is None or (isinstance(value, float) and value != value):
            continue
        seen += 1
        if isinstance(value, bool):
            return False
        if isinstance(value, int) or (isinstance(value, float) and value.is_integer()):
            whole.append(int(value))
        else:
            text.append(str(value))
    if seen == 0:
        return False
    if whole and not text:
        return _int_time_encoding(whole) is not None
    return bool(text) and not whole and all(_DATE_TEXT.match(t) for t in text)


def _physical_through(body, name, dialect, depth):
    """Follow a column name into a CTE or derived table, to the physical column."""
    if depth > MAX_UNWRAP_DEPTH or not isinstance(body, exp.Select):
        return None
    projection = next((e for e in body.expressions
                       if (_output_name(e) or "").lower() == name.lower()), None)
    column = _column_of(projection) if projection is not None else None
    if column is None and not any(isinstance(e, exp.Star) for e in body.expressions):
        return None
    inner_name = column.name if column is not None else name
    if column is not None and column.table:
        return column.table.lower(), inner_name
    frm = _arg(body, "from_", "from")
    source = frm.this if frm else None
    if isinstance(source, exp.Table) and source.name:
        return source.name.lower(), inner_name
    if isinstance(source, exp.Subquery):
        return _physical_through(source.this, inner_name, dialect, depth + 1)
    return None


class Projection:
    __slots__ = ("index", "norm", "measure", "expr")

    def __init__(self, index, norm, measure, expr):
        self.index, self.norm, self.measure, self.expr = index, norm, measure, expr


class Side:
    """One query, read down to the block that actually aggregates."""

    def __init__(self, label, frame, dialect):
        self.label = label
        self.frame = frame
        self.dialect = dialect
        self.projections = []
        self.keys = set()
        self.tables = set()
        self.joins = []
        self.where = None
        self.aggregated = False
        self.single_table = None
        self.single_body = None

    # -- reading -------------------------------------------------------

    @classmethod
    def read(cls, label, sql, frame, dialect, reasons):
        side = cls(label, frame, dialect)
        try:
            parsed = parse_one(sql, dialect=dialect)
        except Exception as exc:
            reasons.append(f"{label}: the SQL does not parse: {exc}")
            return side
        while isinstance(parsed, exp.Subquery):
            parsed = parsed.this
        if not isinstance(parsed, exp.Select):
            reasons.append(f"{label} is not a single SELECT (it is a set operation)")
            return side
        local = []
        side._read(parsed, {}, None, 0, local)
        reasons.extend(local)
        return side

    def _ctes(self, select, inherited):
        visible = dict(inherited)
        with_ = _arg(select, "with_", "with")
        if with_:
            if with_.args.get("recursive"):
                return visible, True
            for cte in with_.expressions:
                body = cte.this
                while isinstance(body, exp.Subquery):
                    body = body.this
                if cte.alias and isinstance(body, exp.Select):
                    visible[cte.alias.lower()] = body
        return visible, False

    def _is_pass_through(self, select):
        """Selects columns from one source, with no filter, join, grouping or dedup."""
        if select.args.get("where") or select.args.get("joins") or select.args.get("distinct"):
            return False
        if select.args.get("group") or select.args.get("having"):
            return False
        for e in select.expressions:
            if isinstance(e, exp.Star) or (isinstance(e, exp.Column) and isinstance(e.this, exp.Star)):
                continue
            if _column_of(e) is None:
                return False
        return True

    def _source_body(self, select, visible):
        frm = _arg(select, "from_", "from")
        source = frm.this if frm else None
        if isinstance(source, exp.Subquery):
            inner = source.this
            while isinstance(inner, exp.Subquery):
                inner = inner.this
            return inner if isinstance(inner, exp.Select) else None
        if isinstance(source, exp.Table) and source.name and not source.args.get("db"):
            body = visible.get(source.name.lower())
            return body if isinstance(body, exp.Select) else None
        return None

    def _read(self, select, inherited, outer_names, depth, reasons):
        if depth > MAX_UNWRAP_DEPTH:
            reasons.append(f"{self.label} nests blocks deeper than this will follow")
            return
        visible, recursive = self._ctes(select, inherited)
        if recursive:
            reasons.append(f"{self.label} has a recursive CTE")
            return

        inner = self._source_body(select, visible) if self._is_pass_through(select) else None
        if inner is not None:
            names = []
            for e in select.expressions:
                if isinstance(e, exp.Star) or (isinstance(e, exp.Column) and isinstance(e.this, exp.Star)):
                    names.extend(_output_name(ie) for ie in inner.expressions)
                else:
                    col = _column_of(e)
                    names.append(col.name if col else None)
            if outer_names is not None:
                mapped = []
                for outer in outer_names:
                    found = next((e for e in select.expressions
                                  if (_output_name(e) or "").lower() == (outer or "").lower()), None)
                    col = _column_of(found) if found is not None else None
                    mapped.append(col.name if col else None)
                names = mapped
            self._read(inner, visible, names, depth + 1, reasons)
            return

        # this block is the one that aggregates -- everything below is read here
        self._read_sources(select, visible, reasons)
        if select.args.get("distinct"):
            reasons.append(f"{self.label} is SELECT DISTINCT, so duplicates are already gone")
        if select.args.get("having"):
            reasons.append(f"{self.label} has a HAVING, a filter applied after aggregation")

        exprs = select.expressions
        for e in exprs:
            if list(e.find_all(exp.Subquery)):
                reasons.append(f"{self.label} has a subquery in its projection")
            if list(e.find_all(exp.Window)):
                reasons.append(f"{self.label} has a window function")

        group = select.args.get("group")
        group_norms = None
        if group is not None:
            group_norms = set()
            for g in group.expressions:
                if isinstance(g, exp.Literal) and not g.is_string:
                    pos = int(float(g.this)) - 1
                    if 0 <= pos < len(exprs):
                        group_norms.add(_norm(exprs[pos], self.dialect))
                else:
                    group_norms.add(_norm(g, self.dialect))

        all_projections = []
        for i, e in enumerate(exprs):
            if isinstance(e, exp.Star) or (isinstance(e, exp.Column) and isinstance(e.this, exp.Star)):
                reasons.append(f"{self.label} has a SELECT *")
                continue
            n = _norm(e, self.dialect)
            measure = bool(list(e.find_all(exp.AggFunc))) or (group_norms is not None and n not in group_norms)
            all_projections.append(Projection(i, n, measure, e))

        if outer_names is None:
            ordered = all_projections
        else:
            ordered = []
            for name in outer_names:
                found = next((p for p in all_projections
                              if name and (_output_name(p.expr) or "").lower() == name.lower()), None)
                if found is None:
                    reasons.append(f"{self.label}: output column '{name}' was not found in the inner projection")
                    return
                ordered.append(found)
        self.projections = [Projection(i, p.norm, p.measure, p.expr) for i, p in enumerate(ordered)]
        self.keys = {p.norm for p in self.projections if not p.measure}
        self.aggregated = any(p.measure for p in self.projections)
        where = select.args.get("where")
        self.where = _norm(where.this, self.dialect) if where else None

    def _read_sources(self, select, visible, reasons):
        frm = _arg(select, "from_", "from")
        sources, bodies = [], []
        if frm:
            sources.append(frm.this)
        for join in select.args.get("joins") or []:
            sources.append(join.this)
            self.joins.append(_norm(join, self.dialect))
        names = []
        for source in sources:
            if isinstance(source, exp.Table) and source.name:
                body = visible.get(source.name.lower())
                if isinstance(body, exp.Select):
                    # A CTE's identity is its body, not its name.
                    names.append("cte:" + _norm(body, self.dialect))
                    bodies.append(body)
                    if self._aggregates(body):
                        reasons.append(f"{self.label} applies a further condition, join or aggregate on top of "
                                       f"an already aggregated CTE or derived table")
                else:
                    names.append(source.name.lower())
            elif isinstance(source, exp.Subquery):
                inner = source.this
                names.append("derived:" + _norm(inner, self.dialect))
                if isinstance(inner, exp.Select):
                    bodies.append(inner)
                if isinstance(inner, exp.Select) and self._aggregates(inner):
                    reasons.append(f"{self.label} applies a further condition, join or aggregate on top of "
                                   f"an already aggregated CTE or derived table")
            else:
                names.append(_norm(source, self.dialect))
        self.tables = set(names)
        plain = [n for n in names if not n.startswith(("cte:", "derived:"))]
        self.single_table = plain[0] if len(names) == 1 and plain else None
        if len(bodies) == 1 and self.single_table is None:
            self.single_body = bodies[0]

    @staticmethod
    def _aggregates(select):
        if select.args.get("group"):
            return True
        return any(list(e.find_all(exp.AggFunc)) for e in select.expressions)

    # -- lookups -------------------------------------------------------

    def index_by_norm(self):
        return {p.norm: p.index for p in self.projections}

    def agg_over(self, agg_type, column_norm):
        for p in self.projections:
            e = _unwrap(p.expr)
            if not isinstance(e, agg_type):
                continue
            col = _column_of(e.this)
            if col is not None and _norm(col, self.dialect) == column_norm:
                return p.index
        return None

    def folds_time(self, folded_norms):
        """Is the axis the coarser side dropped a time axis?

        A name is the usual tell, but not the only one: a column called
        A column carrying dates is a time axis whatever it is called, so the
        values are read too.  Missing this is how a balance gets summed
        across months.
        """
        for p in self.projections:
            if p.norm not in folded_norms:
                continue
            if any(hint in p.norm for hint in TIME_HINTS):
                return True
            if p.index < len(self.frame.columns):
                column = self.frame.columns[p.index]
                if any(hint in str(column).lower() for hint in TIME_HINTS):
                    return True
                if _looks_like_time(self.frame[column]):
                    return True
        return False

    def physical_of(self, column):
        """(table, column) for a column reference, or None when unresolvable.

        A query that reads one CTE or derived table is resolved through it --
        the value is still the same physical column, and refusing to look
        would send every CTE-shaped query to "additivity not declared".
        """
        if column.table:
            return column.table.lower(), column.name
        if self.single_table:
            return self.single_table, column.name
        if self.single_body is not None:
            return _physical_through(self.single_body, column.name, self.dialect, 0)
        return None


# --------------------------------------------------------------------------
# the whitelist: which measures a roll-up may reproduce, and how
# --------------------------------------------------------------------------

# Every plan says: take column ``src`` of the finer table, apply ``op`` within
# each group, and that is the coarser table's column ``dst``.  AVG and ratios
# need a second column, so ``aux`` carries it.  Anything not listed here is
# refused -- the list is a whitelist, so a shape nobody thought about is
# reported, never guessed at.
OP_SUM = "SUM"
OP_MIN = "MIN"
OP_MAX = "MAX"
OP_COUNT_ROWS = "COUNT_ROWS"
OP_COUNT_NON_NULL = "COUNT_NON_NULL"
OP_AVG_OF_ROWS = "AVG_OF_ROWS"
OP_AVG_FROM_SUM_COUNT = "AVG_FROM_SUM_COUNT"
OP_RATIO_OF_SUMS = "RATIO_OF_SUMS"


class Plan:
    __slots__ = ("dst", "src", "op", "aux", "scale", "is_key")

    def __init__(self, dst, src, op=None, aux=None, scale=1.0, is_key=False):
        self.dst, self.src, self.op, self.aux, self.scale, self.is_key = dst, src, op, aux, scale, is_key


def _reject(reasons, projection, why):
    reasons.append(f"{why}: {projection.norm}")
    return None


def _additive(coarse, column, catalog, folds_time, reasons):
    physical = coarse.physical_of(column)
    where = ".".join(physical) if physical else column.name
    declared = catalog.get(physical) if (catalog and physical) else None
    if declared is None:
        reasons.append(f"additivity is undeclared for {where}")
        return False
    if declared == ADDITIVE:
        return True
    if declared == SEMI_ADDITIVE:
        if folds_time:
            reasons.append(f"{where} is semi-additive and cannot be folded along a time axis")
            return False
        return True
    reasons.append(f"{where} is non-additive")
    return False


def _source_index(fine, fine_index, agg_norm, column):
    """The finer side carries the same aggregate, or -- if it is raw -- the column."""
    return fine_index.get(agg_norm) if fine.aggregated else fine_index.get(_norm(column, fine.dialect))


def _plan_measure(m, coarse, fine, fine_index, catalog, folds_time, reasons):
    e = _unwrap(m.expr)

    if isinstance(e, exp.Sum):
        col = _column_of(e.this)
        if col is None:
            return _reject(reasons, m, "the argument of SUM is not a column")
        src = _source_index(fine, fine_index, m.norm, col)
        if src is None:
            return _reject(reasons, m, "the finer side carries no matching SUM")
        if not _additive(coarse, col, catalog, folds_time, reasons):
            return None
        return Plan(m.index, src, OP_SUM)

    if isinstance(e, exp.Count):
        arg = e.this
        if isinstance(arg, exp.Distinct):
            return _reject(reasons, m, "COUNT(DISTINCT) cannot be re-aggregated")
        if fine.aggregated:
            src = fine_index.get(m.norm)
            if src is None:
                return _reject(reasons, m, "the finer side carries no matching COUNT")
            return Plan(m.index, src, OP_SUM)
        if arg is None or isinstance(arg, exp.Star) or isinstance(getattr(arg, "this", None), exp.Star):
            return Plan(m.index, -1, OP_COUNT_ROWS)
        col = _column_of(arg)
        if col is None:
            return _reject(reasons, m, "the argument of COUNT is not a column")
        src = fine_index.get(_norm(col, fine.dialect))
        if src is None:
            return _reject(reasons, m, f"the finer side does not carry column {col.name}")
        return Plan(m.index, src, OP_COUNT_NON_NULL)

    if isinstance(e, (exp.Min, exp.Max)):
        col = _column_of(e.this)
        if col is None:
            return _reject(reasons, m, "the argument of MIN/MAX is not a column")
        src = _source_index(fine, fine_index, m.norm, col)
        if src is None:
            return _reject(reasons, m, "the finer side carries no matching MIN/MAX")
        return Plan(m.index, src, OP_MIN if isinstance(e, exp.Min) else OP_MAX)

    if isinstance(e, exp.Avg):
        col = _column_of(e.this)
        if col is None:
            return _reject(reasons, m, "the argument of AVG is not a column")
        if not _additive(coarse, col, catalog, folds_time, reasons):
            return None
        if fine.aggregated:
            column_norm = _norm(col, fine.dialect)
            sum_idx = fine.agg_over(exp.Sum, column_norm)
            count_idx = fine.agg_over(exp.Count, column_norm)
            if sum_idx is None or count_idx is None:
                return _reject(reasons, m, "the finer side carries no SUM and COUNT to rebuild the AVG from")
            return Plan(m.index, sum_idx, OP_AVG_FROM_SUM_COUNT, aux=count_idx)
        src = fine_index.get(_norm(col, fine.dialect))
        if src is None:
            return _reject(reasons, m, f"the finer side does not carry column {col.name}")
        return Plan(m.index, src, OP_AVG_OF_ROWS)

    # A ratio of two sums re-computes from the two sums, with a literal factor
    # allowed so that a percentage and a fraction are the same plan.
    scale = 1.0
    ratio = e
    if isinstance(ratio, exp.Mul):
        for a, b in ((ratio.this, ratio.expression), (ratio.expression, ratio.this)):
            if isinstance(a, exp.Literal) and not a.is_string:
                scale = float(a.this)
                ratio = _unwrap(b)
                break
    if isinstance(ratio, exp.Div):
        num, den = _unwrap(ratio.this), _unwrap(ratio.expression)
        if isinstance(num, exp.Sum) and isinstance(den, exp.Sum):
            a, b = _column_of(num.this), _column_of(den.this)
            if a is None or b is None:
                return _reject(reasons, m, "the ratio's numerator and denominator are not SUMs of a column")
            ia = _source_index(fine, fine_index, _norm(num, fine.dialect), a)
            ib = _source_index(fine, fine_index, _norm(den, fine.dialect), b)
            if ia is None or ib is None:
                return _reject(reasons, m, "the ratio's numerator and denominator are not carried on the finer side")
            if not _additive(coarse, a, catalog, folds_time, reasons):
                return None
            if not _additive(coarse, b, catalog, folds_time, reasons):
                return None
            return Plan(m.index, ia, OP_RATIO_OF_SUMS, aux=ib, scale=scale)

    return _reject(reasons, m, "an aggregate shape outside the whitelist")


# --------------------------------------------------------------------------
# entry point
# --------------------------------------------------------------------------

NOT_APPLICABLE = "NOT_APPLICABLE"
DERIVABLE = "DERIVABLE"


class Decision:
    """What the two queries permit.  ``plans`` is only set when DERIVABLE."""

    __slots__ = ("kind", "reasons", "plans", "coarse_is_pred", "coarse", "fine")

    def __init__(self, kind, reasons=(), plans=None, coarse_is_pred=None, coarse=None, fine=None):
        self.kind = kind
        self.reasons = list(reasons)
        self.plans = plans
        self.coarse_is_pred = coarse_is_pred
        self.coarse, self.fine = coarse, fine


def decide(gold_sql, pred_sql, gold, pred, catalog=None, dialect=None):
    """Read both queries and say whether a roll-up is permitted, and how.

    Raises nothing: an unreadable query, an unknown shape or a measure that
    cannot be rolled up all come back as UNDECIDABLE with the reason.
    """
    reasons = []
    g = Side.read("gold", gold_sql, gold, dialect, reasons)
    p = Side.read("pred", pred_sql, pred, dialect, reasons)
    if reasons:
        return Decision("UNDECIDABLE", reasons)
    if not g.aggregated and not p.aggregated:
        return Decision(NOT_APPLICABLE)
    if g.keys == p.keys:
        return Decision(NOT_APPLICABLE)

    if g.aggregated and p.keys >= g.keys:
        coarse, fine, coarse_is_pred = g, p, False
    elif p.aggregated and g.keys >= p.keys:
        coarse, fine, coarse_is_pred = p, g, True
    else:
        return Decision("UNDECIDABLE",
                        [f"neither key set contains the other: gold{sorted(g.keys)} vs pred{sorted(p.keys)}"])

    # The same base rows, partitioned two ways -- or it is not a roll-up.
    if coarse.tables != fine.tables:
        reasons.append("the underlying row sets differ: the FROM sources differ, or a CTE or "
                       "derived table of the same name has a different body")
    if coarse.joins != fine.joins:
        reasons.append("the joins differ, so the underlying row sets cannot be shown to match")
    if coarse.where != fine.where:
        reasons.append("the WHERE clauses differ, so the underlying row sets cannot be shown to match")
    if reasons:
        return Decision("UNDECIDABLE", reasons)

    folded = fine.keys - coarse.keys
    folds_time = fine.folds_time(folded)

    plans = []
    fine_index = fine.index_by_norm()
    for key in coarse.projections:
        if key.measure:
            continue
        src = fine_index.get(key.norm)
        if src is None:
            reasons.append(f"the coarser key '{key.norm}' is not in the finer projection")
            continue
        plans.append(Plan(key.index, src, is_key=True))
    for m in coarse.projections:
        if not m.measure:
            continue
        plan = _plan_measure(m, coarse, fine, fine_index, catalog, folds_time, reasons)
        if plan is not None:
            plans.append(plan)
    if reasons:
        return Decision("UNDECIDABLE", reasons)
    return Decision(DERIVABLE, plans=plans, coarse_is_pred=coarse_is_pred,
                    coarse=coarse, fine=fine)


# --------------------------------------------------------------------------
# executing the plan: the data still has to agree
# --------------------------------------------------------------------------

def regroup(decision, fine_frame):
    """Re-aggregate the finer table the way the plan says, one row per group.

    Returns a frame with the coarser table's columns, in its order, or None
    when the plan cannot be executed on these values.  Permission came from
    the queries; agreement has to come from here.
    """
    import pandas as pd

    plans = sorted(decision.plans, key=lambda x: x.dst)
    key_plans = [x for x in plans if x.is_key]
    measure_plans = [x for x in plans if not x.is_key]
    if not measure_plans:
        return None

    groups = {}
    order = []
    for _, row in fine_frame.iterrows():
        try:
            key = tuple(row.iloc[x.src] for x in key_plans)
        except IndexError:
            return None
        if key not in groups:
            groups[key] = []
            order.append(key)
        groups[key].append(row)

    out_rows = []
    for key in order:
        rows = groups[key]
        values = {}
        for x in key_plans:
            values[x.dst] = rows[0].iloc[x.src]
        for x in measure_plans:
            value = _apply(x, rows)
            if value is _UNDEFINED:
                return None
            values[x.dst] = value
        out_rows.append([values[i] for i in sorted(values)])

    width = len(plans)
    names = list(decision.coarse.frame.columns)[:width] if decision.coarse is not None else range(width)
    return pd.DataFrame(out_rows, columns=list(names))


_UNDEFINED = object()


def _numbers(rows, index):
    out = []
    for row in rows:
        value = row.iloc[index]
        if value is None or (isinstance(value, float) and value != value):
            continue
        try:
            out.append(float(value))
        except (TypeError, ValueError):
            return None
    return out


def _apply(plan, rows):
    if plan.op == OP_COUNT_ROWS:
        return float(len(rows))
    if plan.op == OP_COUNT_NON_NULL:
        return float(sum(1 for row in rows
                         if row.iloc[plan.src] is not None
                         and not (isinstance(row.iloc[plan.src], float) and row.iloc[plan.src] != row.iloc[plan.src])))
    values = _numbers(rows, plan.src)
    if values is None:
        # MIN/MAX are defined on text too; everything else needs numbers.
        if plan.op in (OP_MIN, OP_MAX):
            raw = [row.iloc[plan.src] for row in rows if row.iloc[plan.src] is not None]
            if not raw:
                return None
            return min(raw) if plan.op == OP_MIN else max(raw)
        return _UNDEFINED
    if not values:
        return None
    if plan.op == OP_SUM:
        return sum(values)
    if plan.op == OP_MIN:
        return min(values)
    if plan.op == OP_MAX:
        return max(values)
    if plan.op == OP_AVG_OF_ROWS:
        return sum(values) / len(values)
    if plan.op == OP_AVG_FROM_SUM_COUNT:
        counts = _numbers(rows, plan.aux)
        if counts is None or not counts or sum(counts) == 0:
            return _UNDEFINED
        return sum(values) / sum(counts)
    if plan.op == OP_RATIO_OF_SUMS:
        denominators = _numbers(rows, plan.aux)
        if denominators is None or sum(denominators) == 0:
            return _UNDEFINED
        return plan.scale * sum(values) / sum(denominators)
    return _UNDEFINED
