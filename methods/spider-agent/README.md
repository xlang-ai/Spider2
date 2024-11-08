# Spider-Agent

An Agent Method Baseline for Spider 2.0 based on Docker environment.


## 🚀 Quickstart

### Setup

#### 1. Conda Env
```
# Clone the Spider 2.0 repository
git clone https://github.com/xlang-ai/Spider2.git
cd methods/spider-agent

# Optional: Create a Conda environment for Spider 2.0
# conda create -n spider2 python=3.11
# conda activate spider2

# Install required dependencies
pip install -r requirements.txt
```
#### 2. Docker

Follow the instructions in the [Docker setup guide](https://docs.docker.com/engine/install/) to install Docker on your machine.

#### 3. Configure credential
1. To sign up for a BigQuery account, please follow this [guideline](https://github.com/xlang-ai/Spider2/blob/main/assets/Bigquery_Guideline.md).

2. Follow this [guideline](https://github.com/xlang-ai/Spider2/blob/main/assets/Snowflake_Guideline.md) and fill out this [Snowflake form](https://docs.google.com/forms/d/e/1FAIpQLScbVIYcBkADVr-NcYm9fLMhlxR7zBAzg-jaew1VNRj6B8yD3Q/viewform?usp=sf_link), and we will send you an account sign-up email, which will allow you to access the Snowflake database.


#### 4. Download Spider 2.0 Database Source
```
cd spider2

gdown 'https://drive.google.com/uc?id=1OxF-OuPwgb2miQxzftGLZBzPRQtLsyoV'
gdown 'https://drive.google.com/uc?id=1gSB_30ey08GkDrMEXqj3LMJEH4ziQst1'
gdown 'https://drive.google.com/uc?id=1N3f7BSWC4foj-V-1C9n8M2XmgV7FOcqL'
gdown 'https://drive.google.com/uc?id=1s0USV_iQLo4oe05QqAMnhGGp5jeejCzp'

```

#### 5. **Spider 2.0 Setup**
```
python setup.py
```


#### 6. Run Spider-Agent

##### Set LLM API Key

```
export AZURE_API_KEY=your_azure_api_key
export AZURE_ENDPOINT=your_azure_endpoint
export OPENAI_API_KEY=your_openai_api_key
export GEMINI_API_KEY=your_genmini_api_key
```

##### Run 


```python
cd ../../methods/spider-agent
python run.py --suffix <The name of this experiment>
python run.py --model gpt-4o --suffix test1
```

##### Run Arguments

- **`--bq_only`**: Run with BigQuery as the only data source.
- **`--local_only`**: Run with only local files as the data source.
- **`--dbt_only`**: Run exclusively with duckdb dbt-managed data.
- **`--sf_only`**: Run with Snowflake as the only data source.
- **`--ch_only`**: Run with only ClickHouse as the data source.
- **`--pg_only`**: Run exclusively with PostgreSQL data.

### Example

```bash
python run.py --model gpt-4o --suffix experiment_name --bq_only
python run.py --model gpt-4o --suffix experiment_name --bq_only --sf_only --pg_only
```

---



### Evaluation

#### Extract Results

Reorganize run results into a standard submission format, here we store the answer directly into the evaluation suite

```python
python get_spider2_submission_data.py --experiment_suffix <The name of this experiment> --results_folder_name <Standard Submission Folders>
python get_spider2_submission_data.py --experiment_suffix gpt-4o-test1 --results_folder_name ../../spider2/evaluation_suite/gpt-4o-test1
```

#### Run Evaluation Scripts

You can run `evaluate.py` in the [evaluation suite](https://github.com/xlang-ai/Spider2/tree/main/spider2/evaluation_suite) folder of `Spider 2.0` to get the evaluation results.


## Agent Framework

#### Action

- `Bash`: Executes shell commands, such as checking file information, running code, or executing DBT commands.
- `CREATE_FILE`: Creates a new file with specified content.
- `EDIT_FILE`: Edits or overwrites the content of an existing file.
- `BIGQUERY_EXEC_SQL`: Executes a SQL query on BigQuery, with an option to save the results.
- `BQ_GET_TABLES`: Retrieves all table names and schemas from a specified BigQuery dataset.
- `BQ_GET_TABLE_INFO`: Retrieves detailed column information for a specific table in BigQuery.
- `BQ_SAMPLE_ROWS`: Samples a specified number of rows from a BigQuery table and saves them as JSON.
- `Terminate`: Marks the completion of the task, returning the final result or file path.



