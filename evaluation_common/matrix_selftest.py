"""Check the comparator against a grid built to exercise every branch.

The gold set measures what this comparator does to Spider 2.0's own data.  It
cannot check what it does to the shapes that data does not contain: on the
981 alternative-gold pairs the roll-up route fires zero times and the summary
route never fires at all, because the benchmark's row-count multiplicity is
``LIMIT`` and filter choices rather than aggregation grain.  Those paths would
otherwise ship untested.

So the grid here is the coverage the gold set cannot give.  Each case is a
(gold query, gold result, prediction query, prediction result) built to land
on one branch, and the pairs are deliberately two-sided: for every shape the
comparator is meant to decide there is a neighbour it is meant to refuse.  A
whitelist that only ever gets shown what it accepts is a whitelist nobody has
tested the edge of, and widening it silently is exactly the failure that
produces a false pass.

``quvi_verdict`` on each case records what a separate implementation of these
rules -- in Java, over a different SQL parser -- returns for the same input.
It is not what this file asserts; it is checked and reported so that a rule
that holds here only because of how sqlglot happens to parse something shows
up as a disagreement rather than as agreement.

    python matrix_selftest.py            # run, print the grid, exit nonzero on a mismatch
    python matrix_selftest.py --quiet    # only the summary
"""
import argparse
import ast
import io
import json
import math
import os
import sys

import pandas as pd

from relax import relaxed_compare as rc

HERE = os.path.dirname(os.path.abspath(__file__))

# The declared additivity the grid is authored against.  ``inventory.qty`` is left
# out on purpose -- an undeclared measure has to have a case that walks that
# path, because "undeclared" must mean UNDECIDABLE and not "additive".
CATALOG = {
    ("journal", "amount"): "ADDITIVE",
    ("journal", "profit_amount"): "ADDITIVE",
    ("journal", "sales_amount"): "ADDITIVE",
    ("journal", "fee"): "ADDITIVE",
    ("stats", "total_income"): "ADDITIVE",
    ("balances", "balance"): "SEMI_ADDITIVE",
    ("metrics", "margin_rate"): "NON_ADDITIVE",
}


SUITE_DIR = os.path.join(os.path.dirname(HERE), "spider2-snow", "evaluation_suite")


def load_strict_compare():
    """Compile the upstream comparator straight out of evaluate.py.

    Importing evaluate.py would pull in the warehouse clients, so the one
    function is lifted from the parse tree instead.  It is never a copy.
    """
    src = open(os.path.join(SUITE_DIR, "evaluate.py")).read()
    fn = next(n for n in ast.parse(src).body
              if isinstance(n, ast.FunctionDef) and n.name == "compare_pandas_table")
    ns = {"pd": pd, "math": math}
    exec(compile(ast.Module(body=[fn], type_ignores=[]), "evaluate.py", "exec"), ns)
    return ns["compare_pandas_table"]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--cases", default=os.path.join(HERE, "matrix_cases.json"))
    ap.add_argument("--quiet", action="store_true")
    args = ap.parse_args()

    strict = load_strict_compare()
    cases = json.load(open(args.cases))

    failures, disagreements = [], []
    if not args.quiet:
        print(f"{'case':34s} {'expected':16s} {'got':16s} route")
        print("-" * 96)

    for c in cases:
        gold = pd.read_csv(io.StringIO(c["gold_csv"]))
        pred = pd.read_csv(io.StringIO(c["pred_csv"]))
        res = rc.relaxed_compare(pred, gold, strict, [], ignore_order=True,
                                 pred_sql=c["pred_sql"], gold_sql=c["gold_sql"],
                                 additivity=CATALOG)
        ok = res.verdict == c["expect_verdict"] and res.route == c["expect_route"]
        if not ok:
            failures.append((c["id"], c["expect_verdict"], c["expect_route"],
                             res.verdict, res.route))
        # A case with no quvi_verdict has no counterpart run on the Java side --
        # it covers a path only this implementation has.  Not a disagreement.
        if c["quvi_verdict"] is not None and res.verdict != c["quvi_verdict"]:
            disagreements.append((c["id"], c["quvi_verdict"], res.verdict))
        if not args.quiet:
            mark = "" if ok else "   <-- MISMATCH"
            print(f"{c['id']:34s} {c['expect_verdict']:16s} {res.verdict:16s} "
                  f"{res.route}{mark}")

    print(f"\ncases {len(cases)}")
    from collections import Counter
    dist = Counter(c["expect_verdict"] for c in cases)
    print("  " + " / ".join(f"{k} {dist[k]}" for k in
                            ("PASS", "GRAIN_MISMATCH", "UNDECIDABLE", "FAIL")))
    print(f"  routes exercised: {len(set(c['expect_route'] for c in cases))}")

    if disagreements:
        print(f"\ndisagrees with the Java implementation on {len(disagreements)}:")
        for cid, q, f in disagreements:
            print(f"    {cid:34s} java={q:16s} here={f}")
    else:
        checked = sum(1 for c in cases if c["quvi_verdict"] is not None)
        print(f"  agrees with the Java implementation on all {checked} cross-checked")

    if failures:
        print(f"\nMISMATCHES {len(failures)}:")
        for cid, ev, er, gv, gr in failures:
            print(f"    {cid:34s} expected {ev}/{er}  got {gv}/{gr}")
        return 1
    print("\nok")
    return 0


if __name__ == "__main__":
    sys.exit(main())
