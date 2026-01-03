import json
import os
import re
import sqlite3
from pathlib import Path

EVIDENCE_QUESTION_TAMPLATE = """
Given the following external knowledge:
{external_knowledge}
Answer the following question:
{question}
"""

def load_text(path: str) -> str:
    """Load text from file."""
    with open(path, "r") as f:
        return f.read()

def config_inference():
    from transformers import AutoConfig
    config = AutoConfig.from_pretrained("Snowflake/Arctic-Text2SQL-R1-7B")
    print(config.max_position_embeddings)

def build_question_evidence(question, evidence_file_path):
    with open(evidence_file_path, "r") as f:
        evidence = f.read().strip()
    return EVIDENCE_QUESTION_TAMPLATE.format(external_knowledge=evidence, question=question)

def generate_omnistyle_schema(db_folder: str):
    """
    Generate a schema file in omni-style format from a database folder containing JSON table definitions.
    Saves the schema file to omnistyle_schema_sqlite/{db_name}.txt
    """
    db_folder = Path(db_folder)
    db_name = db_folder.name
    
    # Collect all JSON files (table definitions)
    json_files = sorted(db_folder.glob("*.json"))
    
    if not json_files:
        raise ValueError(f"No JSON files found in {db_folder}")
    
    tables = []
    for json_file in json_files:
        with open(json_file, "r", encoding="utf-8") as f:
            table_data = json.load(f)
        
        table_name = table_data.get("table_name", json_file.stem)
        column_names = table_data.get("column_names", [])
        column_types = table_data.get("column_types", [])
        descriptions = table_data.get("description", [""] * len(column_names))
        sample_rows_raw = table_data.get("sample_rows", [])
        
        # Convert sample rows from list of dicts to list of lists
        sample_rows = []
        for row in sample_rows_raw[:2]:  # Take first 2 sample rows
            if isinstance(row, dict):
                sample_rows.append([row.get(col) for col in column_names])
            else:
                sample_rows.append(row)
        
        # Build table schema
        table_schema = {
            "table_name": table_name,
            "table_description": table_data.get("table_description", f"Table containing {table_name} data."),
            "column_names": column_names,
            "column_types": column_types,
            "column_descriptions": descriptions if any(d for d in descriptions) else [f"Column {col}" for col in column_names],
            "primary_key": _infer_primary_key(column_names),
            "sample_rows": sample_rows
        }
        tables.append(table_schema)
    
    # Build the full schema
    schema = {
        "table_num": len(tables),
        "tables": tables,
        "foreign_keys": _infer_foreign_keys(tables)
    }
    
    # Write schema file
    output_file = f"omnistyle_schema_sqlite/{db_name}.txt"
    with open(output_file, "w", encoding="utf-8") as f:
        json.dump(schema, f, indent=2, ensure_ascii=False)
    
    print(f"Generated schema: {output_file}")

def generate_all_omnistyle_schemas(base_path: str, output_dir: str = "omnistyle_schema_sqlite"):
    """
    Loop through all database directories in base_path and generate omnistyle schemas for each.
    
    Args:
        base_path: Path to the directory containing database folders (each with JSON table definitions)
        output_dir: Output directory for generated schema files (default: omnistyle_schema_sqlite)
    """
    base_path = Path(base_path)
    output_path = Path(output_dir)
    output_path.mkdir(parents=True, exist_ok=True)
    
    db_dirs = sorted([d for d in base_path.iterdir() if d.is_dir()])
    
    if not db_dirs:
        raise ValueError(f"No database directories found in {base_path}")
    
    success_count = 0
    error_count = 0
    
    for db_dir in db_dirs:
        try:
            generate_omnistyle_schema(str(db_dir))
            success_count += 1
        except Exception as e:
            print(f"Error processing {db_dir.name}: {e}")
            error_count += 1
    
    print(f"\nCompleted: {success_count} succeeded, {error_count} failed")

def _infer_primary_key(column_names: list[str]) -> list[str]:
    """Infer primary key from column names."""
    # Common primary key patterns
    for col in column_names:
        col_lower = col.lower()
        if col_lower == "id" or col_lower.endswith("_id"):
            return [col]
    # If first column looks like an ID
    if column_names and ("id" in column_names[0].lower()):
        return [column_names[0]]
    return []

def _infer_foreign_keys(tables: list[dict]) -> list[dict]:
    """Infer foreign keys based on column naming conventions."""
    foreign_keys = []
    
    # Build a map of table names to their primary keys
    table_pk_map = {}
    for table in tables:
        table_name = table["table_name"]
        pk = table.get("primary_key", [])
        if pk:
            table_pk_map[table_name] = pk[0]
    
    # Look for foreign key patterns
    for table in tables:
        table_name = table["table_name"]
        for col in table["column_names"]:
            col_lower = col.lower()
            
            # Skip if this is likely the table's own primary key
            if col in table.get("primary_key", []):
                continue
            
            # Check if column references another table
            for ref_table_name, ref_pk in table_pk_map.items():
                if ref_table_name == table_name:
                    continue
                    
                # Match patterns like: customer_id -> customers.customer_id
                # or order_id -> orders.order_id
                ref_table_singular = ref_table_name.rstrip('s')
                if col_lower == ref_pk.lower() or col_lower == f"{ref_table_singular}_{ref_pk}".lower():
                    foreign_keys.append({
                        "source_table": table_name,
                        "column_in_source_table": col,
                        "referenced_table": ref_table_name,
                        "column_in_referenced_table": ref_pk
                    })
                    break
    
    return foreign_keys

def extract_sqlite_constraints(sqlite_path: str) -> dict:
    """
    TODO: Needs verification. Not used yet.
    Extract schema constraints from a SQLite database file.
    
    Args:
        sqlite_path: Path to the .sqlite database file
        
    Returns:
        A dict mapping each table name to its constraints:
        {
            "table_name": {
                "primary_key": ["col1", "col2"],  # list of PK columns
                "foreign_keys": [
                    {
                        "columns": ["col"],
                        "referenced_table": "other_table",
                        "referenced_columns": ["other_col"],
                        "on_update": "NO ACTION",
                        "on_delete": "NO ACTION"
                    }
                ],
                "unique_constraints": [["col1"], ["col2", "col3"]],  # list of unique column sets
                "not_null_columns": ["col1", "col2"],
                "default_values": {"col1": "value", "col2": 0},
                "check_constraints": ["col > 0", ...],
                "columns": [
                    {"name": "col1", "type": "INTEGER", "notnull": True, "default": None, "pk": 1},
                    ...
                ]
            }
        }
    """
    conn = sqlite3.connect(sqlite_path)
    cursor = conn.cursor()
    
    # Get all tables (exclude sqlite internal tables)
    cursor.execute("""
        SELECT name FROM sqlite_master 
        WHERE type='table' AND name NOT LIKE 'sqlite_%' 
        ORDER BY name
    """)
    tables = [row[0] for row in cursor.fetchall()]
    
    result = {}
    
    for table_name in tables:
        table_info = {
            "primary_key": [],
            "foreign_keys": [],
            "unique_constraints": [],
            "not_null_columns": [],
            "default_values": {},
            "check_constraints": [],
            "columns": []
        }
        
        # Get column info including PK, NOT NULL, DEFAULT
        cursor.execute(f"PRAGMA table_info([{table_name}])")
        columns = cursor.fetchall()
        # columns: (cid, name, type, notnull, dflt_value, pk)
        
        for col in columns:
            cid, name, col_type, notnull, default_value, pk = col
            
            table_info["columns"].append({
                "name": name,
                "type": col_type,
                "notnull": bool(notnull),
                "default": default_value,
                "pk": pk
            })
            
            # Collect primary key columns (pk > 0 indicates PK, value is the position in composite PK)
            if pk > 0:
                table_info["primary_key"].append((pk, name))
            
            # Collect NOT NULL columns
            if notnull:
                table_info["not_null_columns"].append(name)
            
            # Collect DEFAULT values
            if default_value is not None:
                table_info["default_values"][name] = default_value
        
        # Sort primary key columns by their position and extract names
        table_info["primary_key"] = [name for _, name in sorted(table_info["primary_key"])]
        
        # Get foreign keys
        cursor.execute(f"PRAGMA foreign_key_list([{table_name}])")
        fk_rows = cursor.fetchall()
        # fk_rows: (id, seq, table, from, to, on_update, on_delete, match)
        
        # Group foreign keys by id (composite FKs have same id, different seq)
        fk_groups = {}
        for fk in fk_rows:
            fk_id, seq, ref_table, from_col, to_col, on_update, on_delete, match = fk
            if fk_id not in fk_groups:
                fk_groups[fk_id] = {
                    "columns": [],
                    "referenced_table": ref_table,
                    "referenced_columns": [],
                    "on_update": on_update,
                    "on_delete": on_delete
                }
            fk_groups[fk_id]["columns"].append((seq, from_col))
            fk_groups[fk_id]["referenced_columns"].append((seq, to_col))
        
        # Sort columns by seq and extract names
        for fk_id, fk_info in fk_groups.items():
            fk_info["columns"] = [col for _, col in sorted(fk_info["columns"])]
            fk_info["referenced_columns"] = [col for _, col in sorted(fk_info["referenced_columns"])]
            table_info["foreign_keys"].append(fk_info)
        
        # Get unique constraints from indexes
        cursor.execute(f"PRAGMA index_list([{table_name}])")
        indexes = cursor.fetchall()
        # indexes: (seq, name, unique, origin, partial)
        
        for idx in indexes:
            idx_seq, idx_name, is_unique, origin, partial = idx
            # origin: 'c' = CREATE INDEX, 'u' = UNIQUE constraint, 'pk' = PRIMARY KEY
            if is_unique and origin == 'u':  # Only UNIQUE constraints, not PKs or manual indexes
                cursor.execute(f"PRAGMA index_info([{idx_name}])")
                idx_cols = cursor.fetchall()
                # idx_cols: (seqno, cid, name)
                unique_cols = [col[2] for col in sorted(idx_cols, key=lambda x: x[0])]
                if unique_cols:
                    table_info["unique_constraints"].append(unique_cols)
        
        # Extract CHECK constraints from DDL (sqlite_master)
        cursor.execute("SELECT sql FROM sqlite_master WHERE type='table' AND name=?", (table_name,))
        ddl_row = cursor.fetchone()
        if ddl_row and ddl_row[0]:
            ddl = ddl_row[0]
            # Simple regex to find CHECK constraints
            check_matches = re.findall(r'CHECK\s*\(([^)]+)\)', ddl, re.IGNORECASE)
            table_info["check_constraints"] = check_matches
        
        result[table_name] = table_info
    
    conn.close()
    return result

def push_csv_to_huggingface(
    csv_path: str,
    repo_id: str,
    token: str = None,
    private: bool = False,
    commit_message: str = "Upload dataset"
):
    """
    Push a CSV file to Hugging Face as a dataset.
    
    Args:
        csv_path: Path to the CSV file to upload
        repo_id: The Hugging Face dataset repository ID (e.g., "username/dataset-name")
        token: Hugging Face token. If None, uses HF_TOKEN environment variable
        private: Whether the dataset should be private (default: False)
        commit_message: Commit message for the upload
    """
    from datasets import Dataset
    import pandas as pd
    
    if token is None:
        token = os.environ.get("HF_TOKEN")
        if token is None:
            raise ValueError("HF_TOKEN environment variable not set and no token provided")
    
    df = pd.read_csv(csv_path)
    dataset = Dataset.from_pandas(df)
    
    dataset.push_to_hub(
        repo_id,
        token=token,
        private=private,
        commit_message=commit_message
    )
    
    print(f"Successfully pushed {csv_path} to https://huggingface.co/datasets/{repo_id}")


if __name__ == "__main__":
    generate_all_omnistyle_schemas("spider2-lite/resource/databases/sqlite")
