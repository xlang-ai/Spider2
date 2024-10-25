# Spider 2.0


Spider 2.0, an evaluation framework with 600 real-world text-to-SQL tasks from enterprise databases. 
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
    - 🏗️ partial project, e.g., [`dbt_project/`](./examples/43d5ad49-0f99-4b90-a6df-d3afc5c216ff/).
    - 🎞️ query history or samples, e.g., [`QUERY_HISTORY/`](./examples/1d009ac3-1c75-447b-a7e0-49ccc2b5fbf9/FIREBASE_QUERY_HISTORY/), [`BASIC_SQLS/`](./examples/e4a35097-4ff3-4ca7-8304-f593e039735b/BASIC_SQLS), etc.
    - 📝 reference documentation: [`ga4_dimensions_and_metrics.md`](./examples/3a348be1-aed2-44fb-8185-c66c9d14a6ef/ga4_dimensions_and_metrics.md), [`retention_rate.md`](./examples/22faca18-f766-46f5-a22b-c79de56fb6ec/retention_rate.md), etc.
    - 🔍 query interface: We have predefined how to access the diverse database systems.



## Configure credential

We have 50% of the examples using a database hosted on BigQuery. If you are not interested in this type of data, please skip this section. If you are interested, **you must** complete the configuration below! You will need to have a BigQuery Account Credential. This will take approximately 1-5 minutes.

We provide two solutions for configuring BigQuery credentials:

### 1. Use Our Free Tier Account Credential

By default, Spider 2.0 uses the BigQuery free tier `bigquery_credential.json`. Due to the quota limitations of the free tier, this could affect the results by approximately **4%**. If you choose to use our free credential, please unzip the credential file:
```bash
unzip credential.zip
python add_credential.py
```

### 2. Use Your Own BigQuery Credential
Due to the quota limit of BigQuery’s free tier, you might encounter [quota limit issues](https://cloud.google.com/bigquery/quotas) when running Spider-Agent. 

In Spider 2.0, we use the free tier `bigquery_credential.json` by default.

To avoid these issues and achieve more accurate results (avoiding the approximately 4% deviation), we recommend that you [register for a BigQuery account](../assets/Bigquery_Guideline.md) and replace the bigquery_credential.json in Spider 2.0 with your own file:

Note that you need to add your [billing account](https://cloud.google.com/billing/docs/how-to/create-billing-account) to your BigQuery account. If you don't do this, there is essentially no difference from using the first solution. **However, this will typically incur a small expense.**

```bash
# move your `bigquery_credential.json` in this folder, must name as `bigquery_credential.json`
python add_credential.py
```


## Baseline

We proposed an agent framework [`Spider-Agent`](../methods/spider-agent) baseline with interactive environment.


## Evaluation

We create [evaluation suite](./evaluation_suite) for Spider 2.0.


#### Evaluation Results


| Method                | Score  |
| --------------------- | ------ |
| Spider-Agent + GPT-4o | 7.36%  |