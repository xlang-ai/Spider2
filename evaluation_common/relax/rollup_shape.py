"""Read the summary rows a query declares, so they can be dropped from its result.

A total row is a derived row: one grouping level lifted off.  Both that it
exists and which result rows it is are things the query already says --
``ROLLUP`` / ``CUBE`` / ``GROUPING SETS`` in the grouping clause, a
``GROUPING(x)`` flag in the projection, a literal covering a key position
(``COALESCE(k, 'TOTAL')``), or a ``UNION ALL`` branch that puts a constant where
the grouped branch puts a key.

Nothing here guesses from the data.  A label list ("total", "all") or "the row
whose numbers are all zero" would mark a region code ``ALL`` and a department
that genuinely sold nothing, and those rows would then be dropped from *both*
sides -- so a prediction that got them wrong would pass.  When the declaration
cannot be read, the right thing is to normalize nothing.

Optional: imported only when sqlglot is installed and the submission carries
SQL.
"""
from __future__ import annotations

import re

from sqlglot import exp, parse_one

COALESCE_NAMES = {"COALESCE", "IFNULL", "NVL", "ISNULL"}


def _arg(node, *names):
    for name in names:
        value = node.args.get(name)
        if value is not None:
            return value
    return None


def _unwrap_alias(e):
    return e.this if isinstance(e, exp.Alias) else e


def _unwrap_subquery(e):
    while isinstance(e, exp.Subquery):
        e = e.this
    return e


def _key(e, dialect=None):
    if e is None:
        return ""
    sql = e.sql(dialect=dialect, comments=False)
    sql = re.sub(r'"([^"]*)"', r"\1", sql)
    sql = re.sub(r"\b[A-Za-z_][A-Za-z0-9_]*\.", "", sql)
    return re.sub(r"\s+", "", sql).lower()


class Shape:
    """Where to look in a result row, and what seeing it means."""

    __slots__ = ("declaration", "markers")

    def __init__(self, declaration, markers):
        self.declaration = declaration
        self.markers = markers          # (kind, column, value)

    def is_summary(self, row):
        for kind, column, value in self.markers:
            if column >= len(row):
                continue
            cell = row[column]
            if kind == "null":
                if cell is None or (isinstance(cell, float) and cell != cell):
                    return True
            elif kind == "flag":
                if _non_zero(cell):
                    return True
            elif str(cell) == value:
                return True
        return False


def _non_zero(value):
    if value is None:
        return False
    if isinstance(value, bool):
        return value
    if isinstance(value, (int, float)):
        return value == value and value != 0
    text = str(value).strip()
    return bool(text) and text != "0"


_GROUPING = getattr(exp, "Grouping", None)


def _grouping_argument(e):
    """The x of GROUPING(x), or None."""
    e = _unwrap_alias(e)
    if _GROUPING is not None and isinstance(e, _GROUPING):
        args = list(e.expressions or [])
        return args[0] if args else (e.this or e)
    if isinstance(e, exp.Anonymous) and str(e.this).upper() == "GROUPING":
        args = list(e.expressions or [])
        return args[0] if args else None
    return None


def _rolled_up_keys(select, dialect):
    """The keys on the axis that gets lifted, or an empty set."""
    group = select.args.get("group")
    keys = set()
    if group is None:
        return keys
    for node in group.walk():
        if isinstance(node, (exp.Rollup, exp.Cube, exp.GroupingSets)):
            for key in node.expressions:
                if isinstance(key, exp.Column):
                    keys.add(_key(key, dialect))
                else:
                    for inner in getattr(key, "expressions", []):
                        keys.add(_key(inner, dialect))
    return keys


def _grouping_keyword(select):
    group = select.args.get("group")
    if group is None:
        return "GROUP BY"
    for node in group.walk():
        if isinstance(node, exp.Rollup):
            return "GROUP BY ROLLUP"
        if isinstance(node, exp.Cube):
            return "GROUP BY CUBE"
        if isinstance(node, exp.GroupingSets):
            return "GROUP BY GROUPING SETS"
    return "GROUP BY"


def _covering_literal(projection, rolled_keys, dialect):
    """The literal that covers a lifted key's NULL, or None."""
    name = type(projection).__name__.upper()
    if isinstance(projection, exp.Coalesce) or (isinstance(projection, exp.Anonymous)
                                                and str(projection.this).upper() in COALESCE_NAMES) \
            or name in COALESCE_NAMES:
        args = [projection.this] + list(projection.expressions or [])
        args = [a for a in args if a is not None]
        if len(args) == 2 and isinstance(args[1], exp.Literal) and args[1].is_string \
                and _key(args[0], dialect) in rolled_keys:
            return args[1].this
        return None
    if isinstance(projection, exp.Case):
        ifs = projection.args.get("ifs") or []
        if len(ifs) != 1:
            return None
        condition = ifs[0].this
        if not any(_grouping_argument(node) is not None for node in condition.walk()):
            return None
        then = ifs[0].args.get("true")
        return then.this if isinstance(then, exp.Literal) and then.is_string else None
    return None


def _union_branch(parsed, dialect):
    """`... GROUP BY k UNION ALL SELECT 'TOTAL', SUM(x) ...` -- common in hand-written reports."""
    if not isinstance(parsed, (exp.Union, exp.Except, exp.Intersect)):
        return None
    left = _unwrap_subquery(parsed.this)
    right = _unwrap_subquery(parsed.expression)
    if not isinstance(left, exp.Select) or not isinstance(right, exp.Select):
        return None
    grouped = left if left.args.get("group") else (right if right.args.get("group") else None)
    if grouped is None:
        return None
    flat = right if grouped is left else left
    if flat.args.get("group") is not None:
        return None
    if len(grouped.expressions) != len(flat.expressions):
        return None
    markers = []
    for i, projection in enumerate(flat.expressions):
        key = _unwrap_alias(grouped.expressions[i])
        if list(key.find_all(exp.AggFunc)):
            continue
        label = _unwrap_alias(projection)
        if isinstance(label, exp.Literal) and label.is_string:
            markers.append(("literal", i, label.this))
    return Shape("constant key on a UNION branch", markers) if markers else None


def _pass_through_projections(select, depth=0):
    """The projections that the result columns actually come from."""
    if depth > 8:
        return select.expressions
    if select.args.get("where") or select.args.get("joins") or select.args.get("distinct"):
        return select.expressions
    if select.args.get("group") or select.args.get("having"):
        return select.expressions
    visible = {}
    with_ = _arg(select, "with_", "with")
    if with_ and not with_.args.get("recursive"):
        for cte in with_.expressions:
            body = _unwrap_subquery(cte.this)
            if cte.alias and isinstance(body, exp.Select):
                visible[cte.alias.lower()] = body
    frm = _arg(select, "from_", "from")
    source = frm.this if frm else None
    inner = None
    if isinstance(source, exp.Subquery):
        inner = _unwrap_subquery(source)
    elif isinstance(source, exp.Table) and source.name:
        inner = visible.get(source.name.lower())
    if not isinstance(inner, exp.Select):
        return select.expressions
    for e in select.expressions:
        if isinstance(e, exp.Star) or (isinstance(e, exp.Column) and isinstance(e.this, exp.Star)):
            return _pass_through_projections(inner, depth + 1)
        if not isinstance(_unwrap_alias(e), exp.Column):
            return select.expressions
    return _pass_through_projections(inner, depth + 1)


def detect(sql, dialect=None):
    """The Shape a query declares, or None."""
    if not sql or not sql.strip():
        return None
    try:
        parsed = parse_one(sql, dialect=dialect)
    except Exception:
        return None
    union = _union_branch(parsed, dialect)
    if union is not None:
        return union
    select = _unwrap_subquery(parsed)
    if not isinstance(select, exp.Select):
        return None
    inner = select
    while True:
        projections = _pass_through_projections(inner)
        if projections is inner.expressions:
            break
        inner = inner            # projections already resolved below
        break
    projections = _pass_through_projections(select)
    # the grouping clause lives on the block that aggregates
    grouped = select
    if projections is not select.expressions:
        for node in select.walk():
            if isinstance(node, exp.Select) and node.args.get("group") is not None:
                grouped = node
                break

    markers = []
    declarations = []
    for i, projection in enumerate(projections):
        if _grouping_argument(projection) is not None:
            markers.append(("flag", i, None))
            declarations.append("GROUPING() flag")
    rolled = _rolled_up_keys(grouped, dialect)
    if rolled:
        declarations.append(_grouping_keyword(grouped))
        for i, projection in enumerate(projections):
            bare = _unwrap_alias(projection)
            literal = _covering_literal(bare, rolled, dialect)
            if literal is not None:
                markers.append(("literal", i, literal))
            elif _key(bare, dialect) in rolled:
                markers.append(("null", i, None))
    if not markers:
        return None
    seen = list(dict.fromkeys(declarations))
    return Shape(" + ".join(seen), markers)


def drop_declared(frame, sql, dialect=None):
    """(frame without its declared summary rows, note) -- or (frame, None)."""
    shape = detect(sql, dialect)
    if shape is None:
        return frame, None
    keep = [i for i, row in enumerate(frame.itertuples(index=False, name=None))
            if not shape.is_summary(row)]
    dropped = frame.shape[0] - len(keep)
    # All rows declared: the answer *is* the total, and dropping leaves nothing.
    if dropped == 0 or not keep:
        return frame, None
    return frame.iloc[keep].reset_index(drop=True), f"{shape.declaration} ({dropped} rows)"
