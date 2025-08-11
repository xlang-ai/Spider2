# Spider-Agent

An Agent Method Baseline for Spider 2.0 based on Docker environment.


## 🚀 Quickstart

### Setup

#### 1. Conda Env
```
# Clone the Spider 2.0 repository
git clone https://github.com/xlang-ai/Spider2.git
cd methods/spider-agent-dbt

# Optional: Create a Conda environment for Spider 2.0
# conda create -n spider2 python=3.11
# conda activate spider2

# Install required dependencies
pip install -r requirements.txt
```
#### 2. Docker

Follow the instructions in the [Docker setup guide](https://docs.docker.com/engine/install/) to install Docker on your machine.


#### 3. Download Spider 2.0 DBT Database Source
```
cd ../../spider2-dbt 
or
cd ./spider2-dbt

gdown 'https://drive.google.com/uc?id=1N3f7BSWC4foj-V-1C9n8M2XmgV7FOcqL'
gdown 'https://drive.google.com/uc?id=1s0USV_iQLo4oe05QqAMnhGGp5jeejCzp'

```

#### 5. **Spider 2.0 DBT Setup**
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
cd ../../methods/spider-agent-dbt
python run.py -s <The name of this experiment>
python run.py --model gpt-4o -s test1
```

### Example

```bash
python run.py --model gpt-4o -s experiment_name
python run.py --model gpt-4o -s experiment_name
```

---



### Evaluation

#### Extract Results

Reorganize run results into a standard submission format, here we store the answer directly into the evaluation suite

```python
python get_spider2_submission_data.py --experiment_suffix <The name of this experiment> --results_folder_name <Standard Submission Folders>
python get_spider2_submission_data.py --experiment_suffix gpt-4o-test1 --results_folder_name ../../spider2-dbt/evaluation_suite/gpt-4o-test1
```

#### Run Evaluation Scripts

You can run `evaluate.py` in the [evaluation suite](https://github.com/xlang-ai/Spider2/tree/main/spider2-dbt/evaluation_suite) folder of `Spider 2.0` to get the evaluation results.


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



