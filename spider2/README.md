# Spider 2.0


Spider 2.0, an evaluation framework with 632 real-world text-to-SQL tasks from enterprise databases. 
These databases, often with over 1,000 columns, come from cloud or local systems like BigQuery, Snowflake, and PostgreSQL.

Solving these tasks requires models to understand database metadata, dialects, and project code, navigating complex SQL environments and handling long contexts. The models must perform advanced reasoning and generate diverse SQL queries, sometimes over 100 lines, surpassing traditional text-to-SQL challenges.


## Data content and format

For [`Spider 2.0`](./README.md), all evaluation examples are aggregated in file [`spider2.jsonl`](./examples/spider2.jsonl), where each data point contains the following field:
```json
{
    "instance_id": "3a348be1-aed2-44fb-8185-c66c9d14a6ef",
    "instruction": "Please tell me the number of sessions for each website traffic channel in December 2020.",
    "type": "Bigquery"
}
```

For each instance, we also provide a separate folder [`./examples/{instruction_id}`](./examples/) as its **Execution Contetxt** to simulate the agentic setting. Each folder may have the following files:

- `README.md`: detailed requirements of the `instruction` field for the current example with `instance_id`;
- `*_credential.json`: credential file connecting to realistic enterprise-level databases, e.g., BigQuery. Can be replaced with your OWN;
- `result.csv`: CSV file to store the execution results;
- other instance-specific materials which assist in finishing the current task:
    - 🏗️ partial project, e.g., [`dbt_project/`](./spider2/examples/airbnb001/).
    - 📝 reference documentation: [`ga4_dimensions_and_metrics.md`](./spider2/examples/ga010/ga4_dimensions_and_metrics.md), [`retention_rate.md`](./spider2/examples/ga022/retention_rate.md), etc.
    - 🔍 query interface: We have predefined how to access the diverse database systems.
    - 🎞️ query history or samples, e.g., [`QUERY_HISTORY/`](./spider2/examples/ga003/FIREBASE_QUERY_HISTORY/), etc.


### Sign Up for Your Own BigQuery and Snowflake Accounts

1. To sign up for a BigQuery account, please follow this [guideline](https://github.com/xlang-ai/Spider2/blob/main/assets/Bigquery_Guideline.md).

2. Follow this [guideline](https://github.com/xlang-ai/Spider2/blob/main/assets/Snowflake_Guideline.md)) and fill out this [Snowflake form](https://docs.google.com/forms/d/e/1FAIpQLScbVIYcBkADVr-NcYm9fLMhlxR7zBAzg-jaew1VNRj6B8yD3Q/viewform?usp=sf_link), and we will send you an account sign-up email, which will allow you to access the Snowflake database.


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
gdown 'https://drive.google.com/uc?id=1coEVsCZq-Xvj9p2TnhBFoFTsY-UoYGmG'
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


## Evaluation

We create [evaluation suite](./evaluation_suite) for Spider 2.0.

