# Spider 2.0-Lite

To align with research interests in **traditional Text2SQL settings**, we released Spider 2.0-Lite. This set is more self-contained, with well-prepared database metadata and documentation, making it a text-in, text-out task that supports faster development and evaluation.


## 🚀 Quickstart

1. Download  [local database](https://drive.usercontent.google.com/download?id=1WRmKgfRylZkRZ080U2QI1hjgph_3iUlq&export=download&authuser=0), unzip and put all the `.sqlite` files into directory `spider2-lite/resource/databases/spider2-localdb`.

2. Usage.
- If your method doesn't require dynamic interaction with the databases, you can make full use of the data in the [`databases`](https://github.com/xlang-ai/Spider2/tree/main/spider2-lite/resource/databases) and the content in the [`documentation`](https://github.com/xlang-ai/Spider2/tree/main/spider2-lite/resource/documents).
- If your method requires dynamic interaction with the database, in addition to these, you can use the scripts in the [`interface`](https://github.com/xlang-ai/Spider2/tree/main/spider2-lite/resource/interface) to interact with the cloud database.

In addition, if you want to view the data in more detail, you need to register for a BigQuery account. Here is a [Bigquery Guideline](https://github.com/xlang-ai/Spider2/blob/main/assets/Bigquery_Guideline.md).

The file `spider2-lite_0930.json` is an older version, while `spider2-lite.json` is the latest version. To address the high query costs associated with large datasets, we have sampled certain tables from `bigquery-public-data` and `patent-public-data` into `spider2-public-data`, making development more efficient and convenient.


## Folder

```
.
├── README.md
├── baselines
│   ├── dailsql  # codebase of method DailSQL
│   ├── codes  # codebase of method CodeS
│   ├── dinsql  # codebase of method CodeS
├── resource
│   ├── databases  
│   │   ├── bigquery
│   │   ├── sqlite
│   │   └── snowflake
│   ├── documents  
│   │   ├── ...markdown files
│   │   └── ...
│   ├── documentation
│   │   ├── bigquery_documentation  # Bigquery official grammar documentation
│   │   ├── bigquery_function   # Bigquery SQL dialect functions
│   │   ├── external_knowledge  # Important external knowledge for examples
│   │   └── snowflake_functions # Snowflake SQL dialect functions
│   └── interface
├── evaluation_suite            # Evaluation Suite for Spider 2.0-Lite
│   ├── README.md
│   ├── bigquery_credential.json
│   ├── snowflake_credential.json
│   ├── evaluate.py
│   ├── gold
│   │   ├── exec_result
│   │   ├── sql
│   └── └── spider2-lite_eval.jsonl
└── spider2-lite.json            # The latest version of Spider 2.0-lite.
```


## Data Content and Format

Each file in `spider2-lite.json` contains the following fields:
- `instance_id`: the unique example id
- `db`: the database id to which this question is addressed
- `question`: the natural language question
- `external_knowledge`: the filenames of external knowledge, documentation, and information required to answer this question are stored in documents
- 
The [`databases`](https://github.com/xlang-ai/Spider2/tree/main/spider2-lite/resource/databases) and the content in [`documentation`](https://github.com/xlang-ai/Spider2/tree/main/spider2-lite/resource/documentation) are resources you can use when benchmarking methods.



```
{
    "instance_id": "ga010",
    "db": "bigquery-public-data.ga4_obfuscated_sample_ecommerce",
    "question": "Can you give me an overview of our website traffic for December 2020? I'm particularly interested in the channel with the fourth highest number of sessions.",
    "external_knowledge": "ga4_dimensions_and_metrics.md"
}
```

The gold SQLs are shown in [evaluation_suite/gold/sql](https://github.com/xlang-ai/Spider2/tree/main/spider2-lite/evaluation_suite/gold/sql).



## Evaluation

We create [evaluation suite](https://github.com/xlang-ai/Spider2/tree/main/spider2-lite/evaluation_suite) for Spider 2.0-Lite.



