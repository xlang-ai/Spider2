# Spider2 Evaluation Suite


## Folder Structure

Please organize your submissions in the following structure:

```
.
├── README.md
├── bigquery_credential.json         # Bigquery
├── evaluate.py                      # main scripts of evaluation 
├── gold                             # gold information of Spider2-SQL (DON'T CHANGE)
│   ├── exec_result                      # Gold execution results
│   ├── sql                              # Gold SQL
│   └── spider2lite_eval.jsonl            # Config file
├── example_submission_folder        # Predicted SQLs
│   ├── bq001.sql
│   ├── bq009.sql
│   └── ...
├── your_predicted_sqls_folder1
├── your_predicted_sqls_folder2
├── ...
└── temp                             # cache
```


## How to evaluate ?

### Credential

Put your own `bigquery_credential.json` and `snowflake_credential.json` in this folder.

### Evaluation

```
python evaluate.py --result_dir <your_predicted_sqls_folder>
```

We provide a sample submissions, `example_submission_folder` 

```
python evaluate.py --result_dir example_submission_folder

```
