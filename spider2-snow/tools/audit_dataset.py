#!/usr/bin/env python3
"""Read-only consistency audit for the Spider 2.0-Snow dataset."""
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any, Iterable

SCHEMA_VERSION = 1
HAVERSINE_DOCUMENT = "haversine_formula.md"
HAVERSINE_CONFLICT_CODE = "HAVERSINE_UNDIRECTED_DOC_DIRECTIONAL_SQL"


def load_jsonl(path: Path) -> list[dict[str, Any]]:
    records = []
    with path.open(encoding="utf-8") as stream:
        for line_number, raw_line in enumerate(stream, start=1):
            if not raw_line.strip():
                continue
            try:
                record = json.loads(raw_line)
            except json.JSONDecodeError as exc:
                raise ValueError(f"{path}:{line_number}: invalid JSON: {exc.msg}") from exc
            if not isinstance(record, dict):
                raise ValueError(f"{path}:{line_number}: expected a JSON object")
            records.append(record)
    return records


def _relative(path: Path, root: Path) -> str:
    try:
        return path.relative_to(root).as_posix()
    except ValueError:
        return str(path)


def _index_gold_results(directory: Path) -> dict[str, list[Path]]:
    index: dict[str, list[Path]] = {}
    if not directory.is_dir():
        return index
    for path in directory.iterdir():
        if not path.is_file() or path.suffix.lower() != ".csv":
            continue
        instance_id = re.sub(r"_[a-z]$", "", path.stem)
        index.setdefault(instance_id, []).append(path)
    return index


def detect_haversine_conflict(document: str, sql: str) -> list[dict[str, str]]:
    """Detect Issue #195's undirected-document/directed-SQL conflict."""
    document = " ".join(document.lower().split())
    sql = " ".join(sql.lower().split())
    document_is_undirected = (
        "symmetry of routes" in document
        and "lexicographically smaller" in document
        and re.search(r"treated\s+the\s+same\s+as\s+a\s+flight\s+from", document)
    )
    sql_groups_directionally = re.search(
        r"group\s+by\s+[\"`]?from_city[\"`]?\s*,\s*[\"`]?to_city[\"`]?", sql
    )
    sql_canonicalizes_pair = re.search(r"\b(?:least|greatest)\s*\(", sql) or (
        re.search(r"\bcase\b", sql)
        and re.search(r"from_city\s*(?:<|<=|>|>=)\s*[\"`]?to_city", sql)
    )
    if document_is_undirected and sql_groups_directionally and not sql_canonicalizes_pair:
        return [{
            "code": HAVERSINE_CONFLICT_CODE,
            "severity": "warning",
            "message": (
                "The Haversine document defines A↔B as an undirected city pair, "
                "but the Gold SQL groups directly by the directional "
                "(from_city, to_city) pair."
            ),
        }]
    return []


def audit_dataset(dataset_path: Path, documents_dir: Path, gold_sql_dir: Path,
                  gold_results_dir: Path) -> dict[str, Any]:
    """Audit references and known conflicts without changing any input."""
    records = load_jsonl(dataset_path)
    root = dataset_path.parent
    result_index = _index_gold_results(gold_results_dir)
    instances = []
    summary = {
        "instances": len(records),
        "with_external_knowledge": 0,
        "missing_external_knowledge": 0,
        "gold_sql_available": 0,
        "gold_sql_unavailable": 0,
        "missing_gold_result": 0,
        "semantic_conflicts": 0,
    }
    for row_number, record in enumerate(records, start=1):
        instance_id = record.get("instance_id")
        if not isinstance(instance_id, str) or not instance_id:
            raise ValueError(f"{dataset_path}:{row_number}: missing non-empty string instance_id")
        external_name = record.get("external_knowledge")
        external_path = documents_dir / external_name if isinstance(external_name, str) else None
        external_exists = external_path.is_file() if external_path else None
        if external_path:
            summary["with_external_knowledge"] += 1
            if not external_exists:
                summary["missing_external_knowledge"] += 1
        sql_path = gold_sql_dir / f"{instance_id}.sql"
        sql_exists = sql_path.is_file()
        if sql_exists:
            summary["gold_sql_available"] += 1
        else:
            summary["gold_sql_unavailable"] += 1
        result_paths = sorted(result_index.get(instance_id, []))
        if not result_paths:
            summary["missing_gold_result"] += 1
        findings = []
        if (external_path and external_exists and external_path.name == HAVERSINE_DOCUMENT
                and sql_exists):
            findings = detect_haversine_conflict(
                external_path.read_text(encoding="utf-8"),
                sql_path.read_text(encoding="utf-8"),
            )
            summary["semantic_conflicts"] += len(findings)
        instances.append({
            "instance_id": instance_id,
            "external_knowledge": {
                "declared": external_name,
                "exists": external_exists,
                "path": _relative(external_path, root) if external_path else None,
            },
            "gold_sql": {"exists": sql_exists, "path": _relative(sql_path, root)},
            "gold_results": {
                "exists": bool(result_paths),
                "paths": [_relative(path, root) for path in result_paths],
            },
            "semantic_findings": findings,
        })
    summary["ok"] = not any(summary[key] for key in (
        "missing_external_knowledge", "missing_gold_result", "semantic_conflicts",
    ))
    return {
        "schema_version": SCHEMA_VERSION,
        "dataset": _relative(dataset_path, root),
        "summary": summary,
        "instances": instances,
    }


def build_parser() -> argparse.ArgumentParser:
    root = Path(__file__).resolve().parents[1]
    parser = argparse.ArgumentParser(
        description="Audit Spider2-Snow references and known semantic conflicts."
    )
    parser.add_argument("--dataset", type=Path, default=root / "spider2-snow.jsonl")
    parser.add_argument("--documents-dir", type=Path, default=root / "resource" / "documents")
    parser.add_argument("--gold-sql-dir", type=Path,
                        default=root / "evaluation_suite" / "gold" / "sql")
    parser.add_argument("--gold-results-dir", type=Path,
                        default=root / "evaluation_suite" / "gold" / "exec_result")
    parser.add_argument("--output", type=Path,
                        help="Write JSON to this path; omit to print to stdout.")
    parser.add_argument("--strict", action="store_true",
                        help=("Exit 1 if required files are missing or a semantic "
                              "conflict is reported; unavailable Gold SQL is allowed."))
    return parser


def main(argv: Iterable[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    try:
        report = audit_dataset(args.dataset.resolve(), args.documents_dir.resolve(),
                               args.gold_sql_dir.resolve(), args.gold_results_dir.resolve())
        serialized = json.dumps(report, ensure_ascii=False, indent=2) + "\n"
        if args.output:
            args.output.write_text(serialized, encoding="utf-8")
        else:
            sys.stdout.write(serialized)
    except (OSError, ValueError) as exc:
        print(json.dumps({"error": str(exc)}, ensure_ascii=False), file=sys.stderr)
        return 2
    return 1 if args.strict and not report["summary"]["ok"] else 0


if __name__ == "__main__":
    raise SystemExit(main())
