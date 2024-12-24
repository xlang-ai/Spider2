# Spider 2.0-Snow Evaluation Suite


## Folder Structure

Please organize your submissions in the following structure:

```
.
├── README.md
├── snowflake_credential.json         # Snowflake username and passworld
├── evaluate.py                      # main scripts of evaluation 
├── gold                             # gold information of Spider2-SQL (DON'T CHANGE)
│   ├── exec_result                      # Gold execution results
│   ├── sql                              # Gold SQL
│   └── spider2snow_eval.jsonl            # Config file
├── example_submission_folder        # Predicted SQLs
│   ├── sf_bq001.sql
│   ├── sf_bq009.sql
│   └── ...
├── your_predicted_sqls_folder1
├── your_predicted_sqls_folder2
├── ...
└── temp                             # cache
```


## How to evaluate ?

### Preliminary TODO

 Follow this [guideline](https://github.com/xlang-ai/Spider2/blob/main/assets/Snowflake_Guideline.md) and fill out this [Spider2 Snowflake Access](https://docs.google.com/forms/d/e/1FAIpQLScbVIYcBkADVr-NcYm9fLMhlxR7zBAzg-jaew1VNRj6B8yD3Q/viewform?usp=sf_link), and we will send you an account sign-up email, which will allow you to access the Snowflake database.


### Credential

Put your own `snowflake_credential.json` in this folder.


### Evaluation

```
python evaluate.py --result_dir <your_predicted_sqls_folder>
```

We provide a sample submissions, `example_submission_folder` 

```
python evaluate.py --result_dir example_submission_folder

```
