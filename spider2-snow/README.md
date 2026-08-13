# Spider 2.0-Snow

To align with research interests in **traditional Text2SQL settings** and **make evaluation more convenient**, we have hosted all the databases used in non-DBT projects from Spider 2.0 on Snowflake (thanks to the support of Snowflake!). In this setting, users only need to use a single SQL dialect to complete tasks, making research in text-to-SQL more focused.


## 🚀 Quickstart

1. **Snowflake Account**: Follow this [guideline](https://github.com/xlang-ai/Spider2/blob/main/assets/Snowflake_Guideline.md) to get your own Snowflake username and password in our snowflake database. You must update `bigquery_credential.json` and `snowflake_credential.json`.


2. Update `bigquery_credential.json` and `snowflake_credential.json`.




### Run Spider-Agent(Snow)

1. **Install Docker**. Follow the instructions in the [Docker setup guide](https://docs.docker.com/engine/install/) to install Docker on your machine. 
2. **Install conda environment**.
```
git clone https://github.com/xlang-ai/Spider2.git
cd methods/spider-agent-snow

# Optional: Create a Conda environment for Spider 2.0
# conda create -n spider2 python=3.11
# conda activate spider2

# Install required dependencies
pip install -r requirements.txt
```
3. **Configure credential**: Follow this [guideline](https://github.com/xlang-ai/Spider2/blob/main/assets/Snowflake_Guideline.md) to get your own Snowflake username and password in our snowflake database. You must update `snowflake_credential.json`.

4. **Spider 2.0-Snow Setup**
```
python spider_agent_setup_snow.py
```

5. **Run agent**
```
export OPENAI_API_KEY=your_openai_api_key
python run.py --model gpt-4o -s test1
```


### Run DAIL-SQL on Spider2-Snow

1. Copy the `spider2-lite/baselines/dailsql` folder to `spider-snow/baselines/dailsql`.

2. Change `DEV=spider2-lite` to `DEV=spider2-snow` in `spider-snow/baselines/dailsql/run.sh`.

3. Run DAIL-SQL on `spider2-snow` in the same way as on `spider-lite`.


## Evaluation

```
python get_spider2snow_submission_data.py --experiment_suffix gpt-4o-test1 --results_folder_name ../../spider2-snow/evaluation_suite/gpt-4o-test1

cd ../../spider2-snow/evaluation_suite
python evaluate.py --mode exec_result --result_dir gpt-4o-test1

```

## Dataset audit

`tools/audit_dataset.py` performs a read-only audit of `spider2-snow.jsonl`. It
checks each declared `external_knowledge` document, records whether Gold SQL is
available, and verifies released execution-result files. Gold SQL is intentionally
not public for every instance, so unavailable Gold SQL is repository policy rather
than a defect. The summary reports this coverage as `gold_sql_available` and
`gold_sql_unavailable`. The audit also reports the known Issue #195 semantic
conflict when the Haversine document specifies an undirected city pair but
available Gold SQL groups directly by the directional `(from_city, to_city)` pair.

From the repository root, run:

```bash
python spider2-snow/tools/audit_dataset.py --output audit-report.json
```

Omit `--output` to emit JSON on stdout. The report contains a summary and one
entry per instance, including matched result variants such as `_a.csv` and all
semantic findings. Normal audit mode exits successfully even when findings are
present. Use `--strict` in CI to return status 1 for missing required files or
semantic conflicts. Unavailable Gold SQL does not make `summary.ok` false and
does not cause strict mode to fail:

```bash
python spider2-snow/tools/audit_dataset.py --strict > audit-report.json
```

All input locations can be overridden with `--dataset`, `--documents-dir`,
`--gold-sql-dir`, and `--gold-results-dir`. Run the dependency-free tests with:

```bash
python -m unittest discover -s spider2-snow/tests -v
```
