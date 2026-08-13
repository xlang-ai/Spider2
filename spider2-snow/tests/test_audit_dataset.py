import importlib.util
import json
from contextlib import redirect_stdout
from io import StringIO
import tempfile
import unittest
from pathlib import Path

MODULE_PATH = Path(__file__).parents[1] / "tools" / "audit_dataset.py"
SPEC = importlib.util.spec_from_file_location("audit_dataset", MODULE_PATH)
audit_dataset = importlib.util.module_from_spec(SPEC)
assert SPEC.loader
SPEC.loader.exec_module(audit_dataset)

UNDIRECTED_DOC = """# Haversine
## Symmetry of Routes
The lexicographically smaller city is first, so a flight from A to B is
 treated the same as a flight from B to A.
"""


class AuditDatasetTest(unittest.TestCase):
    def setUp(self):
        self.temp_dir = tempfile.TemporaryDirectory()
        self.root = Path(self.temp_dir.name)
        self.documents = self.root / "resource" / "documents"
        self.sql = self.root / "evaluation_suite" / "gold" / "sql"
        self.results = self.root / "evaluation_suite" / "gold" / "exec_result"
        for directory in (self.documents, self.sql, self.results):
            directory.mkdir(parents=True)
        self.dataset = self.root / "spider2-snow.jsonl"

    def tearDown(self):
        self.temp_dir.cleanup()

    def write_dataset(self, records):
        self.dataset.write_text(
            "".join(json.dumps(record) + "\n" for record in records),
            encoding="utf-8",
        )

    def audit(self):
        return audit_dataset.audit_dataset(
            self.dataset, self.documents, self.sql, self.results
        )

    def test_complete_files_and_haversine_conflict(self):
        self.write_dataset([{
            "instance_id": "sf_local010",
            "external_knowledge": "haversine_formula.md",
        }])
        (self.documents / "haversine_formula.md").write_text(UNDIRECTED_DOC)
        (self.sql / "sf_local010.sql").write_text(
            'SELECT "from_city", "to_city" FROM routes '
            'GROUP BY "from_city", "to_city"'
        )
        (self.results / "sf_local010_a.csv").write_text("count\n6\n")

        report = self.audit()

        self.assertEqual(1, report["summary"]["semantic_conflicts"])
        self.assertEqual(0, report["summary"]["missing_external_knowledge"])
        self.assertTrue(report["instances"][0]["gold_results"]["exists"])
        finding = report["instances"][0]["semantic_findings"][0]
        self.assertEqual(audit_dataset.HAVERSINE_CONFLICT_CODE, finding["code"])
        self.assertEqual(
            "The Haversine document defines A↔B as an undirected city pair, "
            "but the Gold SQL groups directly by the directional "
            "(from_city, to_city) pair.",
            finding["message"],
        )

    def test_canonicalized_pair_has_no_conflict(self):
        findings = audit_dataset.detect_haversine_conflict(
            UNDIRECTED_DOC,
            "SELECT LEAST(from_city, to_city), GREATEST(from_city, to_city) "
            "FROM routes GROUP BY from_city, to_city",
        )
        self.assertEqual([], findings)

    def test_missing_files_are_reported_and_null_external_is_not_missing(self):
        self.write_dataset([
            {"instance_id": "missing", "external_knowledge": "absent.md"},
            {"instance_id": "no_doc", "external_knowledge": None},
        ])

        report = self.audit()

        self.assertEqual(1, report["summary"]["missing_external_knowledge"])
        self.assertEqual(0, report["summary"]["gold_sql_available"])
        self.assertEqual(2, report["summary"]["gold_sql_unavailable"])
        self.assertEqual(2, report["summary"]["missing_gold_result"])
        self.assertIsNone(report["instances"][1]["external_knowledge"]["exists"])
        self.assertFalse(report["summary"]["ok"])

    def test_exact_result_name_with_underscores_is_indexed(self):
        self.write_dataset([{"instance_id": "sf_bq051", "external_knowledge": None}])
        (self.sql / "sf_bq051.sql").write_text("SELECT 1")
        (self.results / "sf_bq051.csv").write_text("value\n1\n")

        report = self.audit()

        self.assertTrue(report["instances"][0]["gold_results"]["exists"])
        self.assertEqual(1, report["summary"]["gold_sql_available"])
        self.assertEqual(0, report["summary"]["gold_sql_unavailable"])
        self.assertEqual(0, report["summary"]["missing_gold_result"])

    def test_unavailable_gold_sql_does_not_fail_summary_or_strict_mode(self):
        self.write_dataset([{"instance_id": "unreleased", "external_knowledge": None}])
        (self.results / "unreleased.csv").write_text("value\n1\n")

        report = self.audit()

        self.assertEqual(0, report["summary"]["gold_sql_available"])
        self.assertEqual(1, report["summary"]["gold_sql_unavailable"])
        self.assertTrue(report["summary"]["ok"])
        with redirect_stdout(StringIO()):
            exit_code = audit_dataset.main([
                "--dataset", str(self.dataset),
                "--documents-dir", str(self.documents),
                "--gold-sql-dir", str(self.sql),
                "--gold-results-dir", str(self.results),
                "--strict",
            ])
        self.assertEqual(0, exit_code)


if __name__ == "__main__":
    unittest.main()
