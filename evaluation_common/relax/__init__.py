"""A second pass for a result comparison the strict one rejected.

Shared by the sub-benchmark evaluation suites rather than copied into each:
the comparator takes the suite's own ``compare_pandas_table`` as an argument
and never supplies one, so the suites keep their separate strict comparators
(they have drifted from each other) while the rewritings above them stay a
single implementation with a single measurement behind it.

    from relax.relaxed_compare import relaxed_compare_multi

Nothing is re-exported here on purpose: a name bound in this file would shadow
the submodule it came from, and ``relaxed_compare`` is both a module and the
function inside it.

``sqlglot`` is optional.  Without it the query-reading routes are skipped and
everything else behaves as before.
"""
