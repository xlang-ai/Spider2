# Evaluation Suite

## Folder Structure

Please organize your submissions in the following structure:

```
your-submission-folder/
├── results_metadata.jsonl # Contains metadata about each instance's results.
├── instance_002/
│ ├── ...
│ └── result.csv # Results for the instance.
├── instance_003/
│ ├── ...
│ └── other.db # Additional database results.
│ ├── ...
└── ...
```

### Details

`results_metadata.jsonl`: This JSON Lines file should include an entry for each instance with the following structure:

```json
{
    "instance_id": "example_id",
    "answer_type": ["answer", "file"],
    "answer_or_path": "Specified answer or a relative path to the result file"
}
```

- `instance_id`: A unique identifier for each submission.
- `answer_type`: Specifies whether the answer is direct answer (`answer`) or a file path (`file`).
- `answer_or_path`: If `answer_type` is `answer`, this should be the direct answer. If `answer_type` is `file`, this should be the path relative to the instance folder, such as `result.csv` or `db001.db`.

If there are only three instances results to be evaluated, the 'results_metadata.jsonl' should be

```json
{
    "instance_id": "b544e853-00b3-45bc-b3ea-81f195739c60",
    "answer_type": "answer",
    "answer_or_path": 17.5056918%
},
{
    "instance_id": "0bcfa8c4-bc4c-4cd8-9fe5-dd60a2c1f956",
    "answer_type": "answer",
    "answer_or_path": "Google 24oz Ring"
},
{
    "instance_id": "1d009ac3-1c75-447b-a7e0-49ccc2b5fbf9",
    "answer_type": "file",
    "answer_or_path": "output.csv"
}

```

The gold answers are saved in './gold'




### How to use ?


#### Credential

You need to first extract the pre-prepared credential file.
```
unzip credentials.zip
```


```python
python evaluate.py --result_dir <your-submission-folder> --gold_dir gold
python evaluate.py --result_dir example_submission_folder --gold_dir gold
```


### The examples of Gold Evaluation File
```json
{
    "instance_id": "b544e853-00b3-45bc-b3ea-81f195739c60", 
    "evaluation": {
        "func": "number_match", 
        "parameters": {
            "gold": "17.5056918795851%", 
            "percentage": true
        }
    }
},
{
    "instance_id": "0bcfa8c4-bc4c-4cd8-9fe5-dd60a2c1f956", 
    "evaluation": {
        "func": "string_match", 
        "parameters": {
            "gold": ["Google 24oz Ring Bottle Blue"],
            "exclude": ["Google Pen White", "Google Metallic Notebook Set", "Google Red Speckled Tee", "Google Mouse Pad Navy"]
        }
    }
},
{
    "instance_id": "1d009ac3-1c75-447b-a7e0-49ccc2b5fbf9", 
    "evaluation": {
        "func": "table_match", 
        "parameters": {
            "gold": "result.csv", 
            "condition_cols": [1], 
            "ignore_order": true
        }
    }
},
{
    "instance_id": "335fb285-c9fd-45ff-ba8d-fe89a62016f7",
    "instruction": "What is the average minutes spent per visit on the product category that has the highest total quantity bought by users?",
    "type": "Bigquery",
    "derived_from": "bq188",
    "evaluation": {
        "func": "number_match",
        "temporal": true,
        "parameters": {
        }
    }
},
{

}
```

### Evaluation Function

Here is the formatted description of the parameters for the three functions in Markdown:

#### `string_match`


##### Parameters:
- **`pred` (str)**: A string. Don't need to set. It depends on the Agent Method.
- **`gold` (List[str] of str)**: A list of strings to be checked within the pred string.
- **`exclude` (list of str)**: Some strings that can't exist in the pred string.
- **`conj` (str)**: In most cases, no settings are required. The conjunction to use for matching ('and' or 'or'). Defaults to 'or'. 


#### `number_match`


##### Parameters:
- **`pred` (str)**: A string. Don't need to set. It depends on the Agent Method.
- **`gold` (list[str|float] of str)**: A list of numbers to be checked within the pred string.
- **`percentage` (bool)**: Default is false. If the gold answer is related to "percentage", set it to true to make the evaluation robust.
- **`precision`**: In most cases, it doesn't need to be set. Decimal places.
- **`conj` (str)**: In most cases, it doesn't need to be set. The conjunction to use for matching ('and' or 'or'). Defaults to 'or'. Most often 'or'.


#### `table_match`

##### Parameters:
- **`result` (str)**: Path of the CSV file. The result string.
- **`gold` (str|List[str])**: Path of the gold file. Don't provide the root dir. Also support multiple potential gold answers.
- **`condition_cols` (List[int]|List[List[int]])**: A list of column indices used for matching conditions. [0,1] means that the 0th and 1st columns of the gold table need to be considered, while the others are ignored.
- **`ignore_order` (bool)**: A flag to ignore the row order of elements during matching.


#### `duckdb_match`

##### Parameters:
- **`result` (str)**: Path to the DuckDB file containing the result tables.
- **`gold` (str)**: Path to the DuckDB file containing the gold standard tables.
- **`condition_tabs` (List[str], optional)**: List of table names to be checked. If not provided, all tables in the gold DuckDB file will be considered.
- **`condition_cols` (List[List[int]], optional)**: A list of lists, where each inner list contains column indices used for matching conditions for the corresponding table. Defaults to considering all columns.
- **`ignore_orders` (List[bool], optional)**: A list of boolean values indicating whether to ignore the row order for each table comparison. Defaults to [False] for each table.