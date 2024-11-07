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

1. To sign up for a BigQuery account, please follow this [guideline](https://github.com/xlang-ai/Spider2/blob/main/assets/Bigquery_Guideline.md) and fill out the [Spider2 Public Data Access Form](https://docs.google.com/forms/d/e/1FAIpQLSdrsJX-oDZDL0McIaF-0uypLeO2pYW4SX-qDeNSd88iYR_3Gg/viewform).

2. Follow this [guideline](https://github.com/xlang-ai/Spider2/blob/main/assets/Snowflake_Guideline.md)) and fill out this [Snowflake form](https://docs.google.com/forms/d/e/1FAIpQLScbVIYcBkADVr-NcYm9fLMhlxR7zBAzg-jaew1VNRj6B8yD3Q/viewform?usp=sf_link), and we will send you an account sign-up email, which will allow you to access the Snowflake database.



## Baseline

We proposed an agent framework [`Spider-Agent`](../methods/spider-agent) baseline with interactive environment.


## Evaluation

We create [evaluation suite](./evaluation_suite) for Spider 2.0.

