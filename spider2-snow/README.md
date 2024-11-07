# Spider 2.0-Snow

To align with research interests in **traditional Text2SQL settings** and **make evaluation more convenient**, we have hosted all the databases used in non-DBT projects from Spider 2.0 on Snowflake (thanks to the support of Snowflake!). In this setting, users only need to use a single SQL dialect to complete tasks, making research in text-to-SQL more focused.


## 🚀 Quickstart

1. **Snowflake Account**: Follow this [guideline](https://github.com/xlang-ai/Spider2/blob/main/assets/Snowflake_Guideline.md) to get your own Snowflake username and password in our snowflake database. You must update `bigquery_credential.json` and `snowflake_credential.json`.


2. Update `bigquery_credential.json` and `snowflake_credential.json`.




#### Run Spider-Agent(Snow)

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



## Evaluation

```
python get_spider2snow_submission_data.py --experiment_suffix gpt-4o-test1 --results_folder_name ../../spider2-snow/evaluation_suite/gpt-4o-test1

cd ../../spider2-snow/evaluation_suite
python evaluate.py --mode exec_result --result_dir gpt-4o-test1

```