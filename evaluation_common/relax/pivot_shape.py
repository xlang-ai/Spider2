"""Read the pivot a SELECT declares, so a pairing found in data can be checked against it.

Optional: this module is imported only when sqlglot is installed and the
submission carries SQL.  Without it the comparator behaves exactly as before.

Reads the (dimension, value, measure) triple that a wide projection declares:
``AGG(CASE WHEN dim = 'v' THEN m END) AS "label"``, repeated.  Returns None when
the shape is not declared -- never guesses.
"""
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



def _alias_of(projection):
    if isinstance(projection, exp.Alias):
        return projection.alias
    if isinstance(projection, exp.Column):
        return projection.name
    return None


def _column_of(e):
    at = e
    while at is not None:
        if isinstance(at, (exp.Alias, exp.Paren, exp.Cast)):
            at = at.this
        else:
            break
    if isinstance(at, exp.Column) and at.name and not isinstance(at.this, exp.Star):
        return at
    return None


def _normalize(sql):
    if sql is None:
        return ""
    return re.sub(r"\b[A-Za-z_][A-Za-z0-9_]*\.", "", sql).replace(" ", "").lower()


def _is_null_or_zero(e):
    if isinstance(e, exp.Null):
        return True
    if isinstance(e, exp.Literal) and not e.is_string:
        try:
            return float(e.this) == 0.0
        except ValueError:
            return False
    return False


def _as_pivot(index, projection, dialect, allow_filter):
    inner = projection.this if isinstance(projection, exp.Alias) else projection

    # SUM(x) FILTER (WHERE dim = 'v') -- the same triple in another syntax.
    if allow_filter and isinstance(inner, exp.Filter):
        agg, where = inner.this, inner.expression
        if not isinstance(agg, exp.AggFunc):
            return None
        cond = where.this if isinstance(where, exp.Where) else where
        pair = _eq_column_literal(cond)
        if pair is None or agg.this is None:
            return None
        dim, value = pair
        return (index, dim.name, value, _normalize(agg.this.sql(dialect=dialect)),
                type(agg).__name__.upper())

    if not isinstance(inner, exp.AggFunc):
        return None
    case = inner.this
    if not isinstance(case, exp.Case):
        return None
    if case.this is not None:          # simple CASE is not the target
        return None
    ifs = case.args.get("ifs") or []
    if len(ifs) != 1 or not isinstance(ifs[0], exp.If):
        return None
    otherwise = case.args.get("default")
    if otherwise is not None and not _is_null_or_zero(otherwise):
        return None
    pair = _eq_column_literal(ifs[0].this)
    if pair is None:
        return None
    dim, value = pair
    measure = ifs[0].args.get("true")
    if measure is None or not dim.name:
        return None
    return (index, dim.name, value, _normalize(measure.sql(dialect=dialect)),
            type(inner).__name__.upper())


def _eq_column_literal(cond):
    if not isinstance(cond, exp.EQ):
        return None
    left, right = cond.this, cond.expression
    if isinstance(left, exp.Column) and isinstance(right, exp.Literal):
        return left, right.this
    if isinstance(right, exp.Column) and isinstance(left, exp.Literal):
        return right, left.this
    return None


def _pass_through_source(select, visible_ctes):
    if select.args.get("where") or select.args.get("joins") or select.args.get("distinct"):
        return None
    if select.args.get("group") or select.args.get("having"):
        return None
    for e in select.expressions:
        if isinstance(e, exp.Star) or (isinstance(e, exp.Column) and isinstance(e.this, exp.Star)):
            continue
        if _column_of(e) is None:
            return None
    frm = _arg(select, "from_", "from")
    source = frm.this if frm else None
    if isinstance(source, exp.Table) and source.name and not source.args.get("db"):
        body = visible_ctes.get(source.name.lower())
        return body if isinstance(body, exp.Select) else None
    if isinstance(source, exp.Subquery):
        inner = source.this
        while isinstance(inner, exp.Subquery):
            inner = inner.this
        return inner if isinstance(inner, exp.Select) else None
    return None


def _flatten(select, inherited, depth):
    if depth > MAX_UNWRAP_DEPTH:
        return select.expressions
    visible = dict(inherited)
    with_ = _arg(select, "with_", "with")
    if with_:
        if with_.args.get("recursive"):
            return select.expressions
        for cte in with_.expressions:
            body = cte.this
            while isinstance(body, exp.Subquery):
                body = body.this
            if cte.alias and body is not None:
                visible[cte.alias.lower()] = body
    inner = _pass_through_source(select, visible)
    if inner is None:
        return select.expressions
    inner_projections = _flatten(inner, visible, depth + 1)
    out = []
    for e in select.expressions:
        if isinstance(e, exp.Star) or (isinstance(e, exp.Column) and isinstance(e.this, exp.Star)):
            out.extend(inner_projections)
            continue
        ref = _column_of(e)
        found = None
        if ref is not None:
            for cand in inner_projections:
                n = _alias_of(cand)
                if n and n.lower() == ref.name.lower():
                    found = cand
                    break
        if found is None:
            return select.expressions
        out.append(found)
    return out


def detect(sql, dialect=None, allow_filter=True):
    """Return (projection_count, dim_column, [(agg, measure, [values], [indexes])]) or None."""
    if not sql or not sql.strip():
        return None
    try:
        parsed = parse_one(sql, dialect=dialect)
    except Exception:
        return None
    while isinstance(parsed, exp.Subquery):
        parsed = parsed.this
    if not isinstance(parsed, exp.Select):
        return None
    projections = _flatten(parsed, {}, 0)
    pivots = []
    for i, projection in enumerate(projections):
        if isinstance(projection, exp.Star) or (
                isinstance(projection, exp.Column) and isinstance(projection.this, exp.Star)):
            return None
        p = _as_pivot(i, projection, dialect, allow_filter)
        if p is not None:
            pivots.append(p)
    if len(pivots) < 2:
        return None
    dim = pivots[0][1]
    if any(p[1].lower() != dim.lower() for p in pivots):
        return None
    by_measure = {}
    for p in pivots:
        by_measure.setdefault(p[4] + "(" + p[3] + ")", []).append(p)
    groups = []
    canonical = None
    for cols in by_measure.values():
        if len(cols) < 2:
            return None
        values, indexes = [], []
        for c in cols:
            if c[2] in values:
                return None
            values.append(c[2])
            indexes.append(c[0])
        if canonical is None:
            canonical = values
        elif canonical != values:
            return None
        groups.append((cols[0][4], cols[0][3], values, indexes))
    return (len(projections), dim, groups)


def declared_mapping(sql, ncols, dialect=None):
    """The header-to-value pairing the SQL declares, as {column index: value}.

    Returns None when the SQL does not declare a pivot, cannot be parsed, or
    projects a different number of columns than the result carries -- in which
    case position no longer identifies a column and nothing can be concluded.
    """
    shape = detect(sql, dialect=dialect, allow_filter=True)
    if shape is None:
        return None
    projection_count, _dim, groups = shape
    if projection_count != ncols:
        return None
    out = {}
    for _agg, _measure, values, indexes in groups:
        for value, index in zip(values, indexes):
            if index in out and out[index] != value:
                return None
            out[index] = value
    return out or None
