## Spider2 Evaluation v2 README

### Overview
- **Script**: `evaluation_suite/evaluate_v2.py`
- **Purpose**: Compare predicted SQL results against gold results with robust, fair comparison of columns and rows.
- **Key Features**:
  - **Column comparison** with normalization and synonyms
  - **Row comparison** on common normalized columns with tolerant value matching
  - **Gold query execution** (cached) for local instances
  - **Detailed metrics** JSON output per instance and summary
  - **Error logging** to `errors.log` with context and stack traces

### Requirements
- Python 3.9+
- Install packages (example):
  ```bash
  pip install pandas tqdm duckdb google-cloud-bigquery snowflake-connector-python
  ```
  - `sqlite3` is included with Python
  - `google-cloud-bigquery` and `snowflake-connector-python` are only required if you evaluate those modes

### Inputs and Folders
- Predicted results (input):
  - Mode `sql`: a directory with `.sql` files (one per instance)
  - Mode `exec_result`: a directory with `.csv` files (one per instance)
- Gold data (required):
  - `--gold_dir <dir>` containing:
    - `sql/` with gold `.sql` for local instances (e.g., `local357.sql`)
    - `exec_result/` with gold result `.csv` files (cached outputs)
    - `spider2lite_eval.jsonl` (eval rules per instance)
    - `spider2-lite.jsonl` (metadata: db name per instance)
- Local DBs for `local*` instances: `resource/databases/spider2-localdb/<db>.sqlite`

### Running
- From the `spider2-lite` directory:
  ```bash
  # Evaluate predicted SQL files
  python evaluation_suite/evaluate_v2.py \
    --mode sql \
    --result_dir evaluation_suite/predicted_results_folder \
    --gold_dir evaluation_suite/gold

  # Evaluate predicted CSV result files (already executed queries)
  python evaluation_suite/evaluate_v2.py \
    --mode exec_result \
    --result_dir temp \
    --gold_dir evaluation_suite/gold
  ```

### What Happens During Evaluation
- Mode `sql`:
  - For `local*` instances, executes the gold SQL once and caches to `gold/exec_result/<id>.csv` (skips if exists)
  - Executes predicted SQL to `temp/<id>.csv`
  - Compares `temp/<id>.csv` with gold CSV(s)
- Mode `exec_result`:
  - Compares `<result_dir>/<id>.csv` directly with gold CSV(s)

### Column Normalization (Fair Matching)
- Normalization performed consistently across the module via a shared helper:
  - Lowercase, trim whitespace
  - Replace `_` with space
  - Remove common stop-words: `{of, the, a, an}`
  - Harmonize common synonyms word-by-word:
    - `unique→distinct`, `avg→average`, `sum→total`, `count→number`,
      `qty→quantity`, `amt→amount`, `desc→description`, `id→identifier`,
      `max→maximum`, `min→minimum`, `pct/percent→percentage`, `num→number`,
      `cust→customer`, `prod→product`, `trans→transaction`, `cat→category`,
      `grp→group`, `dt→date`, `ts→timestamp`, `pk→primary key`, `fk→foreign key`,
      `cnt/no/nbr→number`, `vol→volume`, `val→value`, `rev→revenue`
- Effect: Matches `week_date` with `Week Date`, `unique_regions` with `Distinct Regions`, etc.

### Row Comparison
- Rows are compared only on the intersection of normalized column names
- Values are normalized before comparison:
  - Strings: case-insensitive (unless `case_sensitive=True` internally)
  - Floats: rounded to tolerance (default `1e-2`)
  - NaN handling unified
- Greedy one-to-one matching to correctly handle duplicates

### Outputs
- Console log mirrored to `log.txt` (via `TeeOutput`)
- Error log with context to `errors.log`
- CSV with correctly matched instance ids: `<result_dir>-ids.csv`
- Detailed metrics file: `<result_dir>-detailed-metrics.json`
  - Summary (averages) of column and row metrics
  - Per-instance details:
    - Column metrics: precision/recall/F1, TP/FP/FN columns
    - Row metrics: precision/recall/F1, TP/FP/FN counts, common columns

### Error Logging
- Centralized logging helpers:
  - `log_error(message, context)` for non-exception failures
  - `log_exception(message, context)` for exceptions (includes stack trace)
- Integrated in:
  - SQLite/BigQuery/Snowflake execution errors
  - Execution failure branches (e.g., `exe_flag == False`)
  - Post-processing exceptions
- See `errors.log` for structured entries (JSON-like context)

### Tips
- Ensure gold exec results exist or allow the script to generate them (local instances)
- If re-running many times, you can clear `temp/` to avoid stale predicted CSVs
- Naming must be consistent: `<instance_id>.sql` / `<instance_id>.csv`

### Example Directory Layout
```
spider2-lite/
  evaluation_suite/
    gold/
      sql/
        local357.sql
        ...
      exec_result/
        local357.csv
        ...
      spider2lite_eval.jsonl
    evaluate_v2.py
  resource/
    databases/
      spider2-localdb/
        <db>.sqlite
  temp/
  log.txt
  errors.log
```

### Notes
- BigQuery and Snowflake are optional; if not used, you can ignore those dependencies
- Column normalization is conservative (word-by-word); if you find a recurring synonym, add it once and all sites benefit