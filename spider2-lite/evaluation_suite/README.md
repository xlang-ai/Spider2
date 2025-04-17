# Spider 2.0-Lite Evaluation Suite


## Folder Structure

Please organize your submissions in the following structure:

```
.
├── README.md
├── bigquery_credential.json         # Bigquery
├── snowflake_credential.json         # Snowflake username and passworld
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

### Preliminary TODO

1. Download  [local database](https://drive.usercontent.google.com/download?id=1coEVsCZq-Xvj9p2TnhBFoFTsY-UoYGmG&export=download&authuser=0), unzip and put all the `.sqlite` files into directory `spider2-lite/resource/databases/spider2-localdb`.

2. To sign up for a BigQuery account, please follow this [guideline](https://github.com/xlang-ai/Spider2/blob/main/assets/Bigquery_Guideline.md), get your own credentials.

3. Follow this [guideline](https://github.com/xlang-ai/Spider2/blob/main/assets/Snowflake_Guideline.md) and fill out this [Spider2 Snowflake Access](https://docs.google.com/forms/d/e/1FAIpQLScbVIYcBkADVr-NcYm9fLMhlxR7zBAzg-jaew1VNRj6B8yD3Q/viewform?usp=sf_link), and we will send you an account sign-up email, which will allow you to access the Snowflake database.


### Credential

Put your own `bigquery_credential.json` and `snowflake_credential.json` in this folder.


### Evaluation

```
python evaluate.py --result_dir <your_predicted_sqls_folder> --mode sql
```

or

```
python evaluate.py --result_dir <your_predicted_CSVs_folder> --mode exec_result
```


We provide a sample submissions, `example_submission_folder` and `example_submission_folder_csv`

```
python evaluate.py --result_dir example_submission_folder --mode sql
```

or

```
python evaluate.py --result_dir example_submission_folder_csv --mode exec_result
```
