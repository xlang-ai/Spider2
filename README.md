# Spider 2.0: Evaluating Language Models on Real-World Enterprise Text-to-SQL Workflows


## 📰 News

<!-- - 2024-10-16: We have cleaned the data in BigQuery, significantly reducing the execution cost of SQL queries. We have now released 80% of the Spider 2.0-lite data, so please stay tuned for updates on the paper and the complete dataset. -->

- 2024-08-28: We released a smaller version of Spider 2.0 (~ 25% of the full dataset) containing 190 examples to give users early access. The full dataset and the paper will be available in two weeks. As this is a preliminary release, there may be errors. Your feedback would be invaluable in refining the dataset. Stay tuned!

## 👋 Overview


![Local Image](./assets/Spider2.png)


### Why Spider 2.0?

In 2018, we introduced [Spider 1.0](https://yale-lily.github.io/spider), [SParC](https://yale-lily.github.io/sparc), and [CoSQL](https://yale-lily.github.io/cosql) as part of the Yale Semantic Parsing and Text-to-SQL Challenge Series, attracting over 300 submissions from leading research labs worldwide.

Now, in the era of Large Language Models (LLMs), we present Spider 2.0 to advance code generation, particularly text-to-SQL capabilities.

This new benchmark offers a more realistic and challenging test of LLMs' performance on complex enterprise-level text-to-SQL workflows, involving complex data environments (e.g., >3000 columns), multiple SQL dialects (e.g., BigQuery, Snowflake), and diverse operations (e.g., transformation, analytics).

Notably, as shown below, even the most advanced LLMs, including GPT-4, solve only 6.0% of Spider 2.0 tasks, compared to 86.6% on Spider 1.0 and 57.4% on BIRD, highlighting the significant challenges posed by Spider 2.0.

|                 | Spider 1.0 dev | Spider 1.0 test | BIRD test | Spider 2.0 |
| --------------- | -------------- | --------------- | --------- | ---------- |
| DailSQL + GPT-4 | 82.4           | 86.6            | 57.4      | 9.4 (on a subset of 319 examples)        |
| CodeS-7B        | 85.4           | -               | 59.3      | 2.2 (on a subset of 319 examples)        |




## 🚀 Quickstart


### Spider 2.0

For [`Spider 2.0`](./spider2/README.md), all evaluation examples are aggregated in file [`spider2.jsonl`](./spider2/examples/spider2.jsonl), where each data point contains the following field:
```json
{
    "instance_id": "3a348be1-aed2-44fb-8185-c66c9d14a6ef",
    "instruction": "Please tell me the number of sessions for each website traffic channel in December 2020.",
    "type": "Bigquery"
}
```
For each instance, we also provide a separate folder [`./spider2/examples/{instruction_id}`](./spider2/examples/) as its **Execution Context** to simulate the agentic setting. Each folder may have the following files:

- `README.md`: detailed requirements of the `instruction` field for the current example with `instance_id`;
- `*_credential.json`: credential file connecting to realistic enterprise-level databases, e.g., BigQuery. Can be replaced with your OWN;
- `result.csv`: CSV file to store the execution results;
- other instance-specific materials which assist in finishing the current task:
    - 🏗️ partial project, e.g., [`dbt_project/`](./spider2/examples/43d5ad49-0f99-4b90-a6df-d3afc5c216ff/).
    - 📝 reference documentation: [`ga4_dimensions_and_metrics.md`](./spider2/examples/3a348be1-aed2-44fb-8185-c66c9d14a6ef/ga4_dimensions_and_metrics.md), [`retention_rate.md`](./spider2/examples/22faca18-f766-46f5-a22b-c79de56fb6ec/retention_rate.md), etc.
    - 🔍 query interface: We have predefined how to access the diverse database systems.
    - 🎞️ query history or samples, e.g., [`QUERY_HISTORY/`](./spider2/examples/1d009ac3-1c75-447b-a7e0-49ccc2b5fbf9/FIREBASE_QUERY_HISTORY/), [`BASIC_SQLS/`](./spider2/examples/e4a35097-4ff3-4ca7-8304-f593e039735b/BASIC_SQLS), etc.

<!-- - `instance_id`: (str) - A formatted instance identifier, UUID
- `instruction`: (str) - The instruction
- `type`: (str) - [Local, Bigquery, DBT, Snowflake]
- `./examples/instanceid/*`: evaluation context
[`examples`](https://github.com/xlang-ai/Spider2/tree/main/spider2/examples). -->

The agent has to interact with complex SQL workflows, process extremely long contexts, perform intricate reasoning, and generate multiple SQL queries with diverse operations, often exceeding 100 lines across multiple turns.


#### Run Spider-Agent

For Spider 2.0, we proposed an agent framework [Spider-Agent](https://github.com/xlang-ai/Spider2/tree/0b1656dd2e82272ca194e6098d4b58a08497f966/spider-agent) based on Docker environment. 

1. **Install Docker**. Follow the instructions in the [Docker setup guide](https://docs.docker.com/engine/install/) to install Docker on your machine. 
2. **Install conda environment**.
```
git clone https://github.com/xlang-ai/Spider2.git
cd methods/spider-agent

# Optional: Create a Conda environment for Spider 2.0
# conda create -n spider2 python=3.11
# conda activate spider2

# Install required dependencies
pip install -r requirements.txt
```
3. **Configure credential**: follow this [instruction](https://github.com/xlang-ai/Spider2/tree/main/spider2#configure-credential) to configure BigQuery for running the SQL queries.
   
4. **Run agent**
```
export OPENAI_API_KEY=your_openai_api_key
python run.py --model gpt-4o --suffix test1
```



### Spider 2.0-Lite

To align with research interests in **traditional Text2SQL settings**, we also release [`Spider 2.0-Lite`](https://github.com/xlang-ai/Spider2/tree/main/spider2-lite#spider-20-lite). This set is more self-contained, with well-prepared database metadata and documentation, making it a text-in, text-out task that supports faster development and evaluation.

You can also access the Spider 2.0-Lite by [huggingface dataset](https://huggingface.co/datasets/xlangai/spider2-lite).🤗
```
from datasets import load_dataset
ds = load_dataset("xlangai/spider2-lite")
```

Each file in `spider2-lite.json` contains the following fields:
- `instance_id`: the unique example id
- `db`: the database id to which this question is addressed
- `question`: the natural language question
- `external_knowledge`: the filenames of external knowledge, documentation, and information required to answer this question are stored in documents


We proposed baselines based on the widely used text2sql methods: [`Dail-SQL`](https://github.com/xlang-ai/Spider2/tree/main/spider2-lite/baselines/dailsql#installation) and [`CodeS`](https://github.com/xlang-ai/Spider2/tree/main/spider2-lite/baselines/codes#installation), with evaluation results reported :test_tube:.

#### Run Dail-SQL

Set up the environment and dependencies:

```bash
conda create -n DAIL-SQL python=3.8
cd spider2-lite/baselines/dailsql
pip install -r requirements.txt
python nltk_downloader.py
pip install https://github.com/explosion/spacy-models/releases/download/en_core_web_sm-3.5.0/en_core_web_sm-3.5.0-py3-none-any.whl
```

Simply run :laughing::
```
bash run.sh
```

For a detailed guideline of running Dail-SQL, please refer to [Installation](https://github.com/xlang-ai/Spider2/tree/main/spider2-lite/baselines/dailsql#installation).


# ✍️ Citation
```



```
