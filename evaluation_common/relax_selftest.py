"""Measure what the relaxed comparator does to Spider 2.0's gold set.

Two axes, run over the shipped gold CSVs alone -- no model, no database.

  positives  pairs of gold files for the *same* question.  The benchmark
             asserts these are the same answer, so a comparator that could
             see through layout and grain would not need both.  Every pair it
             collapses is one alternative gold it makes unnecessary.

  negatives  pairs of gold files for *different* questions.  These are
             different answers.  Every pair the comparator collapses is a
             false pass it introduces, and the number that matters most.

The strict comparator is lifted verbatim out of evaluate.py so the two can
never drift apart.
"""

import argparse
import ast
import json
import math
import os
import random
import re
from collections import defaultdict

import pandas as pd

from relax import relaxed_compare as rc

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)

# Each sub-benchmark ships its own strict comparator and its own gold set, and
# the comparators have drifted from one another, so the measurement is run per
# suite against the suite's own.
SUITES = {
    "snow": ("spider2-snow/evaluation_suite", "gold/spider2snow_eval.jsonl"),
    "lite": ("spider2-lite/evaluation_suite", "gold/spider2lite_eval.jsonl"),
}


def suite_paths(suite):
    rel, eval_rel = SUITES[suite]
    base = os.path.join(ROOT, rel)
    return base, os.path.join(base, "gold", "exec_result"), os.path.join(base, eval_rel)


def load_strict_compare(suite_dir):
    """Compile compare_pandas_table straight out of that suite's evaluate.py."""
    src = open(os.path.join(suite_dir, "evaluate.py")).read()
    tree = ast.parse(src)
    fn = next(n for n in tree.body
              if isinstance(n, ast.FunctionDef) and n.name == "compare_pandas_table")
    ns = {"pd": pd, "math": math}
    exec(compile(ast.Module(body=[fn], type_ignores=[]), "evaluate.py", "exec"), ns)
    return ns["compare_pandas_table"]


# Every route that can declare a pass.  A route carrying ``case`` rested on
# the one fold that is a judgment rather than a repair; they are listed
# separately so refusing that fold is a matter of dropping those rows.
PASS_ROUTES = ("strict", "parse", "case", "unpivot", "unpivot+case")


def _rests_on_case(route: str) -> bool:
    return route == "case" or route.endswith("+case")


def gold_groups(gold_dir):
    groups = defaultdict(list)
    for name in sorted(os.listdir(gold_dir)):
        if not name.endswith(".csv"):
            continue
        qid = re.sub(r"_[a-z]\.csv$", "", name)
        if qid == name:
            qid = name[:-4]
        groups[qid].append(os.path.join(gold_dir, name))
    return groups


# --------------------------------------------------------------------------
# a unit check for the SQL corroboration, on tables written out in full
# --------------------------------------------------------------------------

# The pivot route pairs wide columns with dimension values by searching the
# data.  Below, a prediction has swapped the two months' figures -- a wrong
# answer -- and a pairing that makes the two tables agree still exists, so the
# search finds it.  The gold's query declares which column is which month, and
# that declaration refutes the pairing.  Needs sqlglot; skipped without it.

A1C_GOLD_SQL = """
SELECT account,
       SUM(CASE WHEN month = '1' THEN amount END) AS "jan",
       SUM(CASE WHEN month = '2' THEN amount END) AS "feb"
  FROM ledger
 GROUP BY account
"""


def selftest_sql_corroboration(suite="snow"):
    gold = pd.DataFrame({"account": ["sales", "cost"], "jan": [100, 40], "feb": [120, 50]})
    pred = pd.DataFrame({"account": ["sales", "sales", "cost", "cost"],
                         "month": ["1", "2", "1", "2"],
                         "amount": [120, 100, 50, 40]})     # months swapped: wrong
    strict = load_strict_compare(suite_paths(suite)[0])
    without = rc.relaxed_compare(pred, gold, strict, [], True)
    with_sql = rc.relaxed_compare(pred, gold, strict, [], True, gold_sql=A1C_GOLD_SQL,
                                  sql_dialect="snowflake")
    try:
        import sqlglot            # noqa: F401
    except ImportError:
        print("\n--- SQL corroboration: skipped (sqlglot not installed) ---")
        print(f"  without SQL           {without.verdict} / {without.route}")
        assert without.verdict == rc.PASS, without
        assert with_sql.verdict == rc.PASS, with_sql   # absent parser changes nothing
        return
    print("\n--- SQL corroboration ---")
    print(f"  swapped months, no SQL   {without.verdict} / {without.route}")
    print(f"  swapped months, gold SQL {with_sql.verdict} / {with_sql.route}")
    assert without.verdict == rc.PASS, without
    assert with_sql.verdict == rc.FAIL, with_sql
    print("  ok: the declared pairing withdraws the pass")

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--suite", choices=sorted(SUITES), default="snow")
    ap.add_argument("--gold_dir")
    ap.add_argument("--eval_jsonl")
    ap.add_argument("--negatives", type=int, default=2000)
    ap.add_argument("--seed", type=int, default=0)
    ap.add_argument("--max_cells", type=int, default=200000,
                    help="skip a pair whose tables are larger than this")
    ap.add_argument("--out")
    args = ap.parse_args()

    suite_dir, gold_dir, eval_jsonl = suite_paths(args.suite)
    args.gold_dir = args.gold_dir or gold_dir
    args.eval_jsonl = args.eval_jsonl or eval_jsonl
    strict = load_strict_compare(suite_dir)
    print(f"suite {args.suite}")

    ignore_order = {}
    if os.path.exists(args.eval_jsonl):
        for line in open(args.eval_jsonl):
            item = json.loads(line)
            ignore_order[item["instance_id"]] = item.get("ignore_order", False)

    groups = gold_groups(args.gold_dir)
    multi = {q: f for q, f in groups.items() if len(f) > 1}
    total_files = sum(len(f) for f in groups.values())
    print(f"{total_files} gold files / {len(groups)} questions / "
          f"{len(multi)} with alternatives ({len(multi)/len(groups):.1%})")

    cache = {}

    def read(path):
        if path not in cache:
            try:
                cache[path] = pd.read_csv(path)
            except Exception:
                cache[path] = None
        return cache[path]

    def judge(a_path, b_path, qid, both_directions=False):
        """Compare two result tables.

        Only PASS counts as collapsed; GRAIN_MISMATCH is kept as its own
        bucket on both axes.

        The upstream comparator is asymmetric: every *gold* column must be
        found among the pred columns, so a gold that reports fewer columns is
        satisfied by a prediction that reports more.  Asking whether one gold
        makes another unnecessary is therefore a question about both
        directions, and the positive axis tries both.
        """
        a, b = read(a_path), read(b_path)
        if a is None or b is None:
            return None
        if a.size > args.max_cells or b.size > args.max_cells:
            return None
        io = ignore_order.get(qid, False)
        res = rc.relaxed_compare(a, b, strict, [], io)
        if res.passed or not both_directions:
            return res
        back = rc.relaxed_compare(b, a, strict, [], io)
        if back.passed:
            return back
        return back if back.verdict == rc.GRAIN_MISMATCH else res

    # ---- positives -------------------------------------------------------
    pos = defaultdict(int)
    pos_examples = defaultdict(list)
    pos_pairs = 0
    for qid, files in sorted(multi.items()):
        primary = files[0]
        for alt in files[1:]:
            res = judge(primary, alt, qid, both_directions=True)
            if res is None:
                pos["skipped"] += 1
                continue
            pos_pairs += 1
            pos[res.route if res.passed else res.verdict] += 1
            if res.verdict == rc.GRAIN_MISMATCH and len(pos_examples["derivable"]) < 6:
                pos_examples["derivable"].append(
                    f"{os.path.basename(primary)} ~ {os.path.basename(alt)}: {res.detail}")
            if res.passed and res.route != "strict" and len(pos_examples[res.route]) < 6:
                pos_examples[res.route].append(
                    f"{os.path.basename(primary)} ~ {os.path.basename(alt)}: {res.detail}")

    collapsed = sum(v for k, v in pos.items() if k in PASS_ROUTES)
    beyond = collapsed - pos["strict"]
    on_case = sum(v for k, v in pos.items() if k in PASS_ROUTES and _rests_on_case(k))

    print("\n--- positives: alternative golds of the same question ---")
    print(f"pairs compared        {pos_pairs}")
    for route in PASS_ROUTES:
        print(f"  collapsed / {route:<12} {pos[route]}")
    print(f"  GRAIN_MISMATCH      {pos['GRAIN_MISMATCH']}   (rolls up exactly; reported, not scored)")
    print(f"  FAIL                {pos['FAIL']}")
    print(f"  UNDECIDABLE         {pos['UNDECIDABLE']}")
    print(f"  skipped (too large) {pos['skipped']}")
    if pos_pairs:
        print(f"collapsed total       {collapsed} ({collapsed/pos_pairs:.1%})")
        print(f"  of which beyond the upstream comparator {beyond} ({beyond/pos_pairs:.1%})")
        print(f"  of those, resting on the case fold      {on_case} "
              f"(refusing it leaves {beyond - on_case})")
    for route, ex in pos_examples.items():
        print(f"\n  [{route}]")
        for e in ex:
            print(f"    {e}")

    # ---- negatives -------------------------------------------------------
    rnd = random.Random(args.seed)
    qids = sorted(groups)
    neg = defaultdict(int)
    neg_examples = []
    tried = 0
    while tried < args.negatives:
        qa, qb = rnd.sample(qids, 2)
        a_path, b_path = rnd.choice(groups[qa]), rnd.choice(groups[qb])
        res = judge(a_path, b_path, qa)
        if res is None:
            neg["skipped"] += 1
            tried += 1
            continue
        tried += 1
        neg[res.route if res.passed else res.verdict] += 1
        if res.passed and len(neg_examples) < 20:
            neg_examples.append(
                f"{os.path.basename(a_path)} ~ {os.path.basename(b_path)} "
                f"via {res.route}: {res.detail}")

    judged = tried - neg["skipped"]
    false_pass = sum(v for k, v in neg.items() if k in PASS_ROUTES)
    print("\n--- negatives: gold files of different questions ---")
    print(f"pairs compared        {judged}")
    print(f"  FAIL                {neg['FAIL']}")
    print(f"  UNDECIDABLE         {neg['UNDECIDABLE']}")
    print(f"  GRAIN_MISMATCH      {neg['GRAIN_MISMATCH']}")
    for route in PASS_ROUTES:
        if neg[route]:
            print(f"  FALSE PASS / {route:<12} {neg[route]}")
    if judged:
        print(f"false pass rate       {false_pass}/{judged} = {false_pass/judged:.3%}")
    for e in neg_examples:
        print(f"    {e}")

    report = {
        "gold_files": total_files,
        "questions": len(groups),
        "questions_with_alternatives": len(multi),
        "positives": dict(pos),
        "positive_pairs": pos_pairs,
        "positive_collapsed": collapsed,
        "positive_collapsed_beyond_upstream": beyond,
        "positive_collapsed_resting_on_case_fold": on_case,
        "negatives": dict(neg),
        "negative_pairs": judged,
        "negative_false_pass": false_pass,
    }
    args.out = args.out or os.path.join(HERE, f"relax_selftest_report_{args.suite}.json")
    with open(args.out, "w") as f:
        json.dump(report, f, indent=2)
    print(f"\nreport written to {args.out}")

    selftest_sql_corroboration(args.suite)


if __name__ == "__main__":
    main()
