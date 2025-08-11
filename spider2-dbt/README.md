# Spider 2.0-DBT

Spider 2.0-DBT contains 69 examples of DuckDB data transformation project.

Solving these tasks requires models to understand project code, navigating complex SQL environments and handling long contexts. The models must perform advanced reasoning and generate diverse SQL queries, sometimes over 100 lines, surpassing traditional text-to-SQL challenges.


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

#### 4. **Spider 2.0 DBT Setup**
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

### Example

```bash
python run.py --model gpt-4o --s experiment_name
```


## Evaluation

We create [evaluation suite](./evaluation_suite) for Spider 2.0.

