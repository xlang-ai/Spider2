"""Relaxed result-table comparison for Spider 2.0.

Execution comparison asks whether two result tables are *the same table*.
A question's answer, however, survives two transformations that change the
table without changing the answer:

  1. layout               e.g. months down the rows vs months across the
                          columns -- the same (dimension, value, measure)
                          triples, placed differently
  2. aggregation grain    e.g. one row per (region, month) vs one row per
                          month, where the second is the roll-up of the first

How a figure is *written* is deliberately not in that list.  ``208050000000``
and ``$208.05 billion`` are not the same answer to a question that asked for
a total: the second is a string, and the currency, the rounding and the word
are things the query chose to say.  Likewise ``0.013`` and ``1.3`` -- a
column that differs by a uniform factor is what a unit convention looks like
*and* what an off-by-100 error looks like, and two bare tables carry no
signal that could tell them apart.

Spider 2.0 handles both by enumerating alternative gold files
(``<id>_a.csv`` ... ``<id>_z.csv``).  Enumeration is sound and has a hard
ceiling of 26; one question already carries 22.  This module decides the two
transformations instead of enumerating them.

Design rules
------------
* ``relaxed_compare`` calls the upstream ``compare_pandas_table`` as its only
  equality test, on rewritten inputs.  It therefore **cannot turn a PASS into
  a FAIL** -- the first thing it tries is the unmodified pair.
* The verdict is four-valued: ``PASS`` / ``GRAIN_MISMATCH`` /
  ``UNDECIDABLE`` / ``FAIL``.  Only ``PASS`` is a pass.
  ``GRAIN_MISMATCH`` means the finer result rolls up to the coarser one
  exactly -- reported for review, never scored, because the numbers adding
  up does not show that adding them was what the question asked.
  ``UNDECIDABLE`` is returned whenever the inputs fall outside the class the
  rewriting is justified on.  The boundary is a whitelist, never a blacklist.
* Nothing here reads SQL, a schema, or a declared dimension hierarchy.  Both
  logics run on the two result instances alone.
"""

from __future__ import annotations

import math
import re
from dataclasses import dataclass, field
from itertools import permutations
from typing import Callable, Iterable, Sequence

import pandas as pd

# The verdict names follow the four-valued scheme this comparator came from,
# where PASS and FAIL are what a run scores and the two middle values are
# reported instead of scored.
PASS = "PASS"
FAIL = "FAIL"
UNDECIDABLE = "UNDECIDABLE"
# The finer table rolls up to the coarser one exactly, so the arithmetic is
# not wrong -- but the question fixed a grain and the gold carries it, and
# over-aggregation is a real, common error.  That the numbers add up says
# nothing about whether adding them was meaningful (a total of month-end
# balances adds up and means nothing), and two bare tables carry no signal
# that could tell.  So this is reported, never scored as a pass.
GRAIN_MISMATCH = "GRAIN_MISMATCH"

# Aggregation functions a roll-up may use.  AVG is deliberately absent: the
# average of group averages is not the average of the union, so admitting it
# would accept results that are not derivable.  Ratios and other derived
# measures are excluded for the same reason -- they simply fail to be
# reproduced by any candidate here, which is the intended outcome.
ROLLUP_AGGS = ("sum", "min", "max", "count")

_BARE_NUM_RE = re.compile(r"^[-+]?\d+(?:\.\d+)?(?:[eE][-+]?\d+)?$")


def normalize_scalar(value, fold_case: bool = True):
    """Map a cell to a comparable canonical value, without rewriting how it reads.

    Only differences that no one chose are folded: surrounding whitespace, a
    missing value spelled several ways, and a number that one CSV happens to
    carry as text or as an int where the other carries a float.  How a figure
    is *written* -- a currency symbol, a thousands separator, a magnitude
    word, a percent sign, a date separator -- is not folded, because it is
    part of what the answer says.  A question that asked for a total was not
    answered by a string reading ``$208.05 billion`` unless it asked for that
    string.

    ``fold_case`` is the one fold here that is a judgment rather than a
    repair.  ``Apache-2.0`` and ``APACHE-2.0`` are the same licence, but case
    carries meaning in some domains (gene symbols, where ``ATM`` and ``atm``
    are different things), so the fold is not injective and cannot be
    justified the way the others can.  It is kept separable for that reason:
    the caller decides, and a pass that rests on it is reported under its own
    route so it can be withdrawn without touching anything else.
    """
    if value is None:
        return None
    if isinstance(value, float) and math.isnan(value):
        return None
    if isinstance(value, bool):
        return bool(value)
    if isinstance(value, (int, float)):
        return float(value)

    text = str(value).strip()
    if text == "" or text.lower() in {"nan", "none", "null", "<na>"}:
        return None

    # A bare number that arrived as text is the same value, not another way of
    # writing it -- which side of a CSV round trip it came from is not a
    # choice the query made.
    if _BARE_NUM_RE.match(text):
        try:
            return float(text)
        except ValueError:
            pass

    return text.lower() if fold_case else text


def normalize_frame(df: pd.DataFrame, fold_case: bool = True) -> pd.DataFrame:
    out = df.copy()
    out.columns = [str(c) for c in out.columns]
    for col in out.columns:
        out[col] = out[col].map(lambda v: normalize_scalar(v, fold_case))
    return out


def _value_set(series: pd.Series) -> frozenset:
    return frozenset(v for v in series.tolist() if v is not None)


def _close(a, b, tol: float = 1e-2) -> bool:
    if a is None and b is None:
        return True
    if a is None or b is None:
        return False
    if isinstance(a, (int, float)) and isinstance(b, (int, float)):
        return math.isclose(float(a), float(b), abs_tol=tol)
    return a == b


# --------------------------------------------------------------------------
# canonicalization: wide <-> long
# --------------------------------------------------------------------------

MAX_SPREAD = 12  # largest dimension cardinality a pivot may spread across columns


def _is_numeric_col(series: pd.Series) -> bool:
    vals = [v for v in series.tolist() if v is not None]
    return bool(vals) and all(isinstance(v, float) and not isinstance(v, bool) for v in vals)


def _align_id_columns(wide: pd.DataFrame, long: pd.DataFrame, exclude=()):
    """Pair up the row-identifying columns of a wide and a long table.

    Identity columns carry the same value set on both sides; the wide table
    must be unique over them (one row per identity).  Matching is by value
    set, never by header text.
    """
    pairs = []
    used = set()
    for wc in wide.columns:
        wv = _value_set(wide[wc])
        if not wv:
            continue
        for lc in long.columns:
            if lc in used or lc in exclude:
                continue
            if _value_set(long[lc]) == wv:
                pairs.append((wc, lc))
                used.add(lc)
                break
    return pairs


def unpivot_match(wide: pd.DataFrame, long: pd.DataFrame, tol: float = 1e-2,
                  require: str = "both", required_cols=None):
    """Decide whether ``wide`` is ``long`` with one dimension spread across columns.

    The dimension's values sit in ``long`` as data and in ``wide`` as column
    headers -- but the headers are free text (``avg_pageviews_transactional``
    for the value ``purchase``), so headers are never compared to values.
    Instead the test looks for a bijection between a set of wide columns and
    the dimension's values under which every cell agrees, for every measure.
    A bijection that holds across every row of every measure is the
    definition of the pivot, not a heuristic for it.

    ``require`` says which side must be fully explained: ``"long"`` mirrors
    the upstream rule when the long table is the gold (every gold column is
    accounted for), ``"wide"`` when the wide table is, ``"both"`` for either.
    ``required_cols`` narrows that to the gold's condition columns: the whole
    table still supplies the structure (dimension and identity columns), but
    only the named measures have to be reproduced.
    """
    required_cols = set(required_cols) if required_cols is not None else None
    if wide.shape[0] == 0 or long.shape[0] == 0 or wide.shape[0] >= long.shape[0]:
        return None

    for dim in long.columns:
        dim_values = _value_set(long[dim])
        k = len(dim_values)
        if k < 2 or k > MAX_SPREAD or long.shape[0] % k != 0:
            continue
        if long.shape[0] // k != wide.shape[0]:
            continue

        id_pairs = _align_id_columns(wide, long, exclude=(dim,))
        wide_ids = [w for w, _ in id_pairs]
        long_ids = [l for _, l in id_pairs]
        if wide_ids and wide.duplicated(subset=wide_ids).any():
            continue
        if long_ids and long.duplicated(subset=long_ids + [dim]).any():
            continue

        long_measures = [c for c in long.columns
                         if c != dim and c not in long_ids and _is_numeric_col(long[c])]
        wide_spread_pool = [c for c in wide.columns
                            if c not in wide_ids and _is_numeric_col(wide[c])]
        if required_cols is not None:
            if require == "long":
                long_measures = [c for c in long_measures if c in required_cols]
            elif require == "wide":
                must_spread = [c for c in wide_spread_pool if c in required_cols]
        if not long_measures or len(wide_spread_pool) < k:
            continue

        # row identity -> value, for each side
        def wide_vec(col):
            keys = list(zip(*[wide[w].tolist() for w in wide_ids])) if wide_ids else [()] * wide.shape[0]
            return dict(zip(keys, wide[col].tolist()))

        def long_vec(col, value):
            sub = long[long[dim] == value]
            keys = list(zip(*[sub[l].tolist() for l in long_ids])) if long_ids else [()] * sub.shape[0]
            return dict(zip(keys, sub[col].tolist()))

        def same(d1, d2):
            if set(d1) != set(d2):
                return False
            return all(_close(d1[key], d2[key], tol) for key in d1)

        wide_cache = {c: wide_vec(c) for c in wide_spread_pool}
        used_wide = set()
        mapping = []
        ok = True
        for lm in long_measures:
            targets = {v: long_vec(lm, v) for v in dim_values}
            chosen = {}
            for v, tvec in targets.items():
                hit = next((wc for wc in wide_spread_pool
                            if wc not in used_wide and wc not in chosen.values()
                            and same(wide_cache[wc], tvec)), None)
                if hit is None:
                    break
                chosen[v] = hit
            if len(chosen) != k:
                if require in ("long", "both"):
                    ok = False
                    break
                continue
            used_wide.update(chosen.values())
            mapping.append((lm, chosen))
        if not ok or not mapping:
            continue
        if require == "wide" and required_cols is not None:
            if set(must_spread) - used_wide:
                continue
        elif require in ("wide", "both") and set(wide_spread_pool) - used_wide:
            continue
        return {"dim": dim, "ids": id_pairs, "measures": mapping}
    return None


# --------------------------------------------------------------------------
# corroboration: the pairing the SQL declares
# --------------------------------------------------------------------------

# ``unpivot_match`` finds a pairing between wide columns and dimension values
# by searching the data: it accepts if *some* pairing makes every cell agree.
# That is an existential test, so a prediction that permuted its measures
# across the pivot axis -- a wrong answer -- is matched under the permuted
# pairing.  When the wide side's SQL is in hand, the pairing is not a matter
# of search: the query declares it.  Reading it can only withdraw a pass,
# never grant one, so this check is consulted after a match is found and its
# absence leaves the comparator exactly as it was.


def _declared_pivot(sql, ncols, dialect=None):
    if not sql:
        return None
    try:
        from . import pivot_shape                      # optional: needs sqlglot
    except Exception:
        return None
    try:
        return pivot_shape.declared_mapping(sql, ncols, dialect)
    except Exception:
        return None


def sql_contradicts_unpivot(wide: pd.DataFrame, match, sql, dialect=None) -> bool:
    """True when the SQL pairs a wide column with a different dimension value.

    Silent (False) whenever the SQL is absent, unparsable, declares no pivot,
    or projects a different number of columns than the result carries: those
    are cases with nothing to say, not evidence of agreement.
    """
    declared = _declared_pivot(sql, wide.shape[1], dialect)
    if not declared:
        return False
    position = {col: i for i, col in enumerate(wide.columns)}
    for _measure, chosen in match["measures"]:
        for value, wide_col in chosen.items():
            index = position.get(wide_col)
            if index is None or index not in declared:
                continue
            if normalize_scalar(declared[index]) != normalize_scalar(value):
                return True
    return False


def _vectors_equal(v1, v2, tol, ignore_order):
    if len(v1) != len(v2):
        return False
    if ignore_order:
        v1 = sorted(v1, key=lambda x: (x is None, str(x)))
        v2 = sorted(v2, key=lambda x: (x is None, str(x)))
    return all(_close(a, b, tol) for a, b in zip(v1, v2))


# --------------------------------------------------------------------------
# derivability: is the coarse table a roll-up of the fine one?
# --------------------------------------------------------------------------

@dataclass
class Derivation:
    key_pairs: list = field(default_factory=list)   # (coarse col, fine col)
    measure_pairs: list = field(default_factory=list)  # (coarse col, fine col, agg)

    def describe(self) -> str:
        keys = ", ".join(f"{a}~{b}" for a, b in self.key_pairs)
        meas = ", ".join(f"{a}={agg}({b})" for a, b, agg in self.measure_pairs)
        return f"group by [{keys}] with {meas}"


def _key_candidates(coarse: pd.DataFrame, fine: pd.DataFrame):
    """Columns of ``coarse`` that could be grain keys, with their matches.

    A grain key of the coarser result must carry exactly the values the finer
    result groups over -- equal value sets, not merely overlapping ones.  That
    equality is what rules out a coarser table produced by an extra filter
    (a ``HAVING`` clause, say) rather than by a roll-up.
    """
    pairs = {}
    for c in coarse.columns:
        cv = _value_set(coarse[c])
        if not cv or len(cv) == coarse.shape[0] == 1:
            continue
        matches = [f for f in fine.columns if _value_set(fine[f]) == cv]
        if matches:
            pairs[c] = matches
    return pairs


def find_derivation(coarse: pd.DataFrame, fine: pd.DataFrame,
                    tol: float = 1e-2, required_cols=None) -> Derivation | None:
    """Return a derivation of ``coarse`` from ``fine``, or None.

    The test is the definition, not an approximation of it: group the finer
    table by the matched keys, aggregate, and require the result to reproduce
    the coarser table row for row.  A candidate aggregation function is
    accepted only if it reproduces *every* row of a measure column, so an
    accidental match would have to hold across the whole column.
    """
    if coarse.shape[0] == 0 or fine.shape[0] == 0:
        return None
    if coarse.shape[0] >= fine.shape[0]:
        return None

    cand = _key_candidates(coarse, fine)
    if not cand:
        return None

    key_cols = list(cand.keys())
    if coarse.duplicated(subset=key_cols).any():
        return None

    # Assign each coarse key column a distinct fine column.
    assignment = None
    for combo in permutations(range(max(len(m) for m in cand.values()))):
        pick, used, ok = [], set(), True
        for c in key_cols:
            choice = next((f for f in cand[c] if f not in used), None)
            if choice is None:
                ok = False
                break
            used.add(choice)
            pick.append((c, choice))
        if ok:
            assignment = pick
            break
        if combo:
            break
    if not assignment:
        return None

    fine_keys = [f for _, f in assignment]
    grouped = fine.groupby(fine_keys, dropna=False, sort=False)
    if grouped.ngroups != coarse.shape[0]:
        # every coarse row must be exactly one group of the fine table, and
        # the fine table must contribute no group the coarse table drops
        return None

    coarse_measures = [c for c in coarse.columns if c not in key_cols]
    if required_cols is not None:
        coarse_measures = [c for c in coarse_measures if c in set(required_cols)]
    fine_measures = [f for f in fine.columns if f not in fine_keys]
    if not coarse_measures:
        return None
    # A roll-up aggregates measures, and a measure is a number.  A non-key
    # text column on the coarse side has no aggregate that produces it, so
    # the pair is outside the class this test is justified on.
    if any(not _is_numeric_col(coarse[c]) for c in coarse_measures):
        return None

    index = coarse.set_index([c for c, _ in assignment])
    derivation = Derivation(key_pairs=list(assignment))
    used_fine = set()

    for cm in coarse_measures:
        target = index[cm]
        matched = None
        for fm in fine_measures:
            if fm in used_fine:
                continue
            for agg in ROLLUP_AGGS:
                try:
                    rolled = grouped[fm].agg(agg)
                except (TypeError, ValueError, pd.errors.DataError):
                    continue
                try:
                    rolled = rolled.reindex(target.index)
                except (TypeError, ValueError):
                    continue
                if rolled.isna().all() and not target.isna().all():
                    continue
                if all(_close(a, b, tol) for a, b in zip(target.tolist(), rolled.tolist())):
                    matched = (cm, fm, agg)
                    break
            if matched:
                break
        if not matched:
            return None
        used_fine.add(matched[1])
        derivation.measure_pairs.append(matched)

    return derivation


def drop_declared_summary_rows(pred, gold, pred_sql, gold_sql, dialect):
    """Drop each side's *declared* total rows.  Returns (pred, gold, notes).

    Only the side whose query declares them loses rows -- if one query rolls
    up and the other does not, only the first has total rows to drop.  Nothing
    is inferred from labels or from a row of zeros: that would drop a region
    code ``ALL`` and a department that genuinely sold nothing from *both*
    sides, and a prediction that got those rows wrong would then pass.
    """
    if not pred_sql and not gold_sql:
        return pred, gold, []
    try:
        from . import rollup_shape                 # optional: needs sqlglot
    except Exception:
        return pred, gold, []
    notes = []
    try:
        if pred_sql:
            pred, note = rollup_shape.drop_declared(pred, pred_sql, dialect)
            if note:
                notes.append("pred " + note)
        if gold_sql:
            gold, note = rollup_shape.drop_declared(gold, gold_sql, dialect)
            if note:
                notes.append("gold " + note)
    except Exception:
        return pred, gold, []
    return pred, gold, notes


# --------------------------------------------------------------------------
# derivability, when the queries are in hand
# --------------------------------------------------------------------------

# The data-only roll-up check asks whether the numbers add up.  It cannot ask
# the prior question -- whether adding them was defined -- because that lives
# in the queries and in what the values mean: COUNT(DISTINCT) summed over
# parts overcounts what the parts share, HAVING has already dropped rows, a
# different JOIN fans them out, and a month-end balance is not summable along
# time however neatly it adds.  When both queries are available the prior
# question is answered first, and the data still has to agree afterwards.


def sql_derivability(pred, gold, pred_sql, gold_sql, catalog, dialect, strict_compare,
                     condition_cols, ignore_order):
    """(verdict, route, detail) from reading both queries, or None to fall through."""
    if not pred_sql or not gold_sql:
        return None
    try:
        from . import derivability_sql as ds       # optional: needs sqlglot
    except Exception:
        return None
    try:
        decision = ds.decide(gold_sql, pred_sql, gold, pred, catalog, dialect)
    except Exception:
        return None
    if decision.kind == ds.NOT_APPLICABLE:
        # The queries group by the same keys, or neither aggregates: a roll-up
        # is not what is going on, so the tables differing is the answer.  The
        # data-only path would reach for a grain key it cannot find and report
        # UNDECIDABLE, which reads as "cannot say" about a pair we can say
        # about.
        return (FAIL, "not-a-rollup", "the two sides group at the same grain, so a roll-up is not the question")
    if decision.kind == UNDECIDABLE:
        return (UNDECIDABLE, "derivable-sql", " / ".join(decision.reasons))
    try:
        regrouped = ds.regroup(decision, decision.fine.frame)
    except Exception:
        regrouped = None
    if regrouped is None:
        return (UNDECIDABLE, "derivable-sql", "the plan the queries allow could not be run on the values")
    coarse = decision.coarse.frame
    direction = ("pred is the roll-up of gold" if decision.coarse_is_pred
                 else "gold is the roll-up of pred")
    try:
        agreed = bool(strict_compare(regrouped, coarse, [], ignore_order))
    except Exception:
        agreed = False
    if agreed:
        return (GRAIN_MISMATCH, "derivable-sql", direction)
    return (FAIL, "derivable-sql", f"re-aggregated {direction}, and the values do not match")


# --------------------------------------------------------------------------
# entry point
# --------------------------------------------------------------------------

@dataclass
class RelaxedResult:
    verdict: str
    route: str = "strict"
    detail: str = ""

    @property
    def passed(self) -> bool:
        return self.verdict == PASS


def relaxed_compare(
    pred: pd.DataFrame,
    gold: pd.DataFrame,
    strict_compare: Callable[..., int],
    condition_cols: Sequence | None = None,
    ignore_order: bool = False,
    tol: float = 1e-2,
    pred_sql: str | None = None,
    gold_sql: str | None = None,
    sql_dialect: str | None = None,
    additivity: dict | None = None,
) -> RelaxedResult:
    """Compare two result tables under canonicalization and derivability.

    ``strict_compare`` is the upstream comparator and is the only thing that
    ever declares two tables equal.  It is tried first on the untouched
    inputs, so a pair the upstream comparator passes is passed here by the
    same code path and the same reasoning.
    """
    if condition_cols is None or condition_cols == []:
        condition_cols = []
    elif not isinstance(condition_cols, (list, tuple)):
        condition_cols = [condition_cols]
    else:
        condition_cols = list(condition_cols)

    def agree(a: pd.DataFrame, b: pd.DataFrame, cols=None) -> bool:
        try:
            return bool(strict_compare(a, b, cols if cols is not None else [], ignore_order))
        except Exception:
            return False

    if agree(pred, gold, condition_cols):
        return RelaxedResult(PASS, "strict")

    # A total row is a derived row, and the query says which one it is.
    pred, gold, summary_notes = drop_declared_summary_rows(pred, gold, pred_sql, gold_sql,
                                                           sql_dialect)
    if summary_notes and agree(pred, gold, condition_cols):
        return RelaxedResult(PASS, "summary", "; ".join(summary_notes))

    # The upstream comparator scores a gold on its condition columns only.
    # The rewritings are shown the same restriction, so they can neither
    # demand a column the strict comparison does not, nor be satisfied by one.
    # Two normalizations, because one of the folds is a judgment and the rest
    # are repairs.  ``repaired`` fixes only what a CSV round trip did to a
    # cell; ``folded`` additionally folds letter case.  Every route is tried
    # on ``repaired`` first, so a pass is attributed to the case fold only
    # when it actually needed it -- and dropping the fold means dropping
    # exactly the routes whose name carries ``case``.
    try:
        repaired = (normalize_frame(pred, fold_case=False),
                    normalize_frame(gold, fold_case=False))
        folded = (normalize_frame(pred, fold_case=True),
                  normalize_frame(gold, fold_case=True))
    except Exception as exc:
        return RelaxedResult(UNDECIDABLE, "normalize", str(exc))

    # Column-vector routes see the gold on its condition columns, as the
    # strict comparison does.  Structural routes (pivot, roll-up) see the
    # whole gold -- the dimension and identity columns are the structure --
    # and are required to reproduce only the condition columns.
    def restrict(ngold_full):
        if not condition_cols:
            return ngold_full, None
        sliced = ngold_full.iloc[:, condition_cols]
        return sliced, list(sliced.columns)

    try:
        restricted = {name: restrict(frames[1]) for name, frames in
                      (("repaired", repaired), ("folded", folded))}
    except (IndexError, TypeError):
        return RelaxedResult(UNDECIDABLE, "condition_cols", "could not apply condition_cols")

    # Not a rewriting of how the answer reads -- only a repair of what a CSV
    # round trip did to it (a number carried as text or as an int, surrounding
    # whitespace, a missing value spelled several ways).
    npred, ngold_full = repaired
    ngold, required = restricted["repaired"]
    if agree(npred, ngold):
        return RelaxedResult(PASS, "parse")

    # The one judgment: two spellings of the same word.  Reported on its own
    # so it can be refused without refusing the routes above or below.
    if agree(folded[0], restricted["folded"][0]):
        return RelaxedResult(PASS, "case", "the values differ only in letter case")

    # -- canonicalization: pivot --------------------------------------------
    def try_pivot(npred, ngold_full, required):
        match = unpivot_match(npred, ngold_full, tol, require="long", required_cols=required)
        if match is not None:
            if sql_contradicts_unpivot(npred, match, pred_sql, sql_dialect):
                return RelaxedResult(FAIL, "unpivot-sql",
                                     "the pairing that makes the tables agree is not the "
                                     "one the prediction's SQL declares")
            return RelaxedResult(PASS, "unpivot", "pred is wide, gold is long")
        match = unpivot_match(ngold_full, npred, tol, require="wide", required_cols=required)
        if match is not None:
            if sql_contradicts_unpivot(ngold_full, match, gold_sql, sql_dialect):
                return RelaxedResult(FAIL, "unpivot-sql",
                                     "the pairing that makes the tables agree is not the "
                                     "one the gold's SQL declares")
            return RelaxedResult(PASS, "unpivot", "gold is wide, pred is long")
        return None

    for tag, (np_, ngf_) in (("", repaired), ("+case", folded)):
        try:
            found = try_pivot(np_, ngf_, restricted["repaired" if not tag else "folded"][1])
        except Exception:
            found = None
        if found is not None:
            return RelaxedResult(found.verdict, found.route + tag, found.detail)

    # -- derivability -------------------------------------------------------
    decided = sql_derivability(pred, gold, pred_sql, gold_sql, additivity, sql_dialect,
                               strict_compare, condition_cols, ignore_order)
    if decided is not None:
        return RelaxedResult(decided[0], decided[1], decided[2])

    # Same two passes as the pivot: the grain keys are matched on values, so a
    # column whose labels differ only in case would otherwise look like a
    # different key.  Reported as ``derivable+case`` when the fold was needed.
    for tag, (np_, ngf_) in (("", repaired), ("+case", folded)):
        if np_.shape[0] == ngf_.shape[0]:
            continue
        req_for = restricted["repaired" if not tag else "folded"][1]
        if np_.shape[0] < ngf_.shape[0]:
            coarse, fine, direction, req = np_, ngf_, "pred is the roll-up of gold", None
        else:
            coarse, fine, direction, req = ngf_, np_, "gold is the roll-up of pred", req_for
        try:
            derivation = find_derivation(coarse, fine, tol=tol, required_cols=req)
        except Exception:
            derivation = None
        if derivation is not None:
            return RelaxedResult(GRAIN_MISMATCH, "derivable" + tag,
                                 f"{direction}: {derivation.describe()}")

    if _outside_decidable_class(folded[0], folded[1]):
        return RelaxedResult(UNDECIDABLE, "out-of-class",
                             "no grain keys with matching value sets")
    return RelaxedResult(FAIL, "exhausted")


def _outside_decidable_class(a: pd.DataFrame, b: pd.DataFrame) -> bool:
    """True when the pair falls outside what the rewritings are justified on.

    Reported separately from FAIL so that a run can say how much of the
    corpus the boundary excluded rather than silently counting it as wrong.
    """
    if a.shape[0] == b.shape[0]:
        return False
    coarse, fine = (a, b) if a.shape[0] < b.shape[0] else (b, a)
    return not _key_candidates(coarse, fine)


def relaxed_compare_multi(
    pred: pd.DataFrame,
    golds: Iterable[pd.DataFrame],
    strict_compare: Callable[..., int],
    condition_cols=None,
    ignore_order: bool = False,
    pred_sql: str | None = None,
    gold_sqls: Sequence | None = None,
    sql_dialect: str | None = None,
    additivity: dict | None = None,
) -> RelaxedResult:
    golds = list(golds)
    # One SQL per gold, positionally.  An alternative gold ships as a CSV with
    # no query of its own, so its entry is None and that gold is compared
    # without corroboration.
    sqls = list(gold_sqls) if gold_sqls is not None else []
    sqls += [None] * (len(golds) - len(sqls))
    # Mirror compare_multi_pandas_table's handling of condition_cols exactly:
    # one list for every gold, or one list per gold, indexed by position.
    if condition_cols in ([], [[]], [None], None):
        per_gold = [[] for _ in golds]
    elif len(golds) > 1 and not all(isinstance(c, list) for c in condition_cols):
        per_gold = [condition_cols for _ in golds]
    else:
        per_gold = [condition_cols[i] if i < len(condition_cols) else []
                    for i in range(len(golds))]

    last = RelaxedResult(FAIL, "exhausted")
    for gold, cols, gold_sql in zip(golds, per_gold, sqls):
        res = relaxed_compare(pred, gold, strict_compare, cols, ignore_order,
                              pred_sql=pred_sql, gold_sql=gold_sql,
                              sql_dialect=sql_dialect, additivity=additivity)
        if res.passed:
            return res
        if res.verdict in (GRAIN_MISMATCH, UNDECIDABLE):
            last = res
    return last
