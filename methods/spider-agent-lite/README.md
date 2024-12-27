# Spider-Agent-Lite

An Agent Method Baseline for Spider 2.0-Lite based on Docker environment.

## 🚀 Quickstart

#### Run Spider-Agent(Lite)

1. **Install Docker**. Follow the instructions in the [Docker setup guide](https://docs.docker.com/engine/install/) to install Docker on your machine. 
2. **Install conda environment**.
```
git clone https://github.com/xlang-ai/Spider2.git
cd methods/spider-agent-lite

# Optional: Create a Conda environment for Spider 2.0
# conda create -n spider2 python=3.11
# conda activate spider2

# Install required dependencies
pip install -r requirements.txt
```
3. **Configure credential**: You must update `snowflake_credential.json` and `bigquery_credential.json`.

Biguqery: To sign up for a BigQuery account, please follow this [guideline](https://github.com/xlang-ai/Spider2/blob/main/assets/Bigquery_Guideline.md).

Snowflake: Follow this [guideline](https://github.com/xlang-ai/Spider2/blob/main/assets/Snowflake_Guideline.md)) and fill out this [Snowflake form](https://docs.google.com/forms/d/e/1FAIpQLScbVIYcBkADVr-NcYm9fLMhlxR7zBAzg-jaew1VNRj6B8yD3Q/viewform?usp=sf_link), and we will send you an account sign-up email, which will allow you to access the Snowflake database.


4. **Spider 2.0-Lite Setup**
```
gdown 'https://drive.google.com/uc?id=1coEVsCZq-Xvj9p2TnhBFoFTsY-UoYGmG' -O ../../spider2-lite/resource/
rm -rf ../../spider2-lite/resource/databases/spider2-localdb
mkdir -p ../../spider2-lite/resource/databases/spider2-localdb
unzip ../../spider2-lite/resource/local_sqlite.zip -d ../../spider2-lite/resource/databases/spider2-localdb

python spider_agent_setup_lite.py
```

5. **Run agent**
```
export OPENAI_API_KEY=your_openai_api_key
python run.py --model gpt-4o -s test1
```




### Evaluation

#### Extract Results

Reorganize run results into a standard submission format, here we store the answer directly into the evaluation suite

```python
python get_spider2lite_submission_data.py --experiment_suffix <The name of this experiment> --results_folder_name <Standard Submission Folders>
python get_spider2lite_submission_data.py --experiment_suffix gpt-4o-test1 --results_folder_name ../../spider2-lite/evaluation_suite/gpt-4o-test1
```

#### Run Evaluation Scripts

You can run `evaluate.py` in the [evaluation suite](https://github.com/xlang-ai/Spider2/tree/main/spider2-lite/evaluation_suite) folder of `spider2-lite` to get the evaluation results.


```bash
python evaluate.py --result_dir gpt-4o-test1 --mode exec_result
```


