#coding=utf8
import re
from dataclasses import dataclass, field
from typing import Optional, Any, Union, List, Dict
from abc import ABC

def remove_quote(text: str) -> str:
    """ 
    If the text is wrapped by a pair of quote symbols, remove them.
    In the middle of the text, the same quote symbol should remove the '/' escape character.
    """
    for quote in ['"', "'", "`"]:
        if text.startswith(quote) and text.endswith(quote):
            text = text[1:-1]
            text = text.replace(f"\\{quote}", quote)
            break
    return text.strip()


@dataclass
class Action(ABC):
    
    action_type: str = field(
        repr=False,
        metadata={"help": 'type of action, e.g. "exec_code", "create_file", "terminate"'}
    )


    @classmethod
    def get_action_description(cls) -> str:
        return """
Action: action format
Description: detailed definition of this action type.
Usage: example cases
Observation: the observation space of this action type.
"""

    @classmethod
    def parse_action_from_text(cls, text: str) -> Optional[Any]:
        raise NotImplementedError

@dataclass
class Bash(Action):

    action_type: str = field(
        default="exec_code",
        init=False,
        repr=False,
        metadata={"help": 'type of action, c.f., "exec_code"'}
    )

    code: str = field(
        metadata={"help": 'command to execute'}
    )

    @classmethod
    def get_action_description(cls) -> str:
        return """
## Bash Action
* Signature: Bash(code="shell_command")
* Description: This action string will execute a valid shell command in the `code` field. Only non-interactive commands are supported. Commands like "vim" and viewing images directly (e.g., using "display") are not allowed.
* Example: Bash(code="ls -l")
"""

    @classmethod
    def parse_action_from_text(cls, text: str) -> Optional[Action]:
        matches = re.findall(r'Bash\(code=(.*?)\)', text, flags=re.DOTALL)
        if matches:
            code = matches[-1]
            return cls(code=remove_quote(code))
        return None
    
    def __repr__(self) -> str:
        return f'{self.__class__.__name__}(code="{self.code}")'
    
    

@dataclass
class CreateFile(Action):

    action_type: str = field(
        default="create_file",
        init=False,
        repr=False,
        metadata={"help": 'type of action, c.f., "create_file"'}
    )

    code: str = field(
        metadata={"help": 'code to write into file'}
    )

    filepath: Optional[str] = field(
        default=None,
        metadata={"help": 'name of file to create'}
    )

    def __repr__(self) -> str:
        return f"CreateFile(filepath=\"{self.filepath}\"):\n```\n{self.code.strip()}\n```"

    @classmethod
    def get_action_description(cls) -> str:
        return """
## CreateFile
Signature: CreateFile(filepath="path/to/file"):
```
file_content
```
Description: This action will create a file in the field `filepath` with the content wrapped by paired ``` symbols. Make sure the file content is complete and correct. If the file already exists, you can only use EditFile to modify it.
Example: CreateFile(filepath="hello_world.py"):
```
print("Hello, world!")
```
"""

    @classmethod
    def parse_action_from_text(cls, text: str) -> Optional[Action]:
        matches = re.findall(r'CreateFile\(filepath=(.*?)\).*?```[ \t]*(\w+)?[ \t]*\r?\n(.*)[\r\n \t]*```', text, flags=re.DOTALL)
        if matches:
            filepath = matches[-1][0].strip()
            code = matches[-1][2].strip()
            return cls(code=code, filepath=remove_quote(filepath))
        return None
    
    def __repr__(self) -> str:
        return f"{self.__class__.__name__}(filepath='{self.filepath}':\n'''\n{self.code}\n''')"
       
@dataclass
class EditFile(Action):
    action_type: str = field(default="edit_file",init=False,repr=False,metadata={"help": 'type of action, c.f., "edit_file"'})

    code: str = field(metadata={"help": 'code to write into file'})

    filepath: Optional[str] = field(default=None,metadata={"help": 'name of file to edit'})

    def __repr__(self) -> str:
        return f"EditFile(filepath=\"{self.filepath}\"):\n```\n{self.code.strip()}\n```"

    @classmethod
    def get_action_description(cls) -> str:
        return """
## EditFile
Signature: EditFile(filepath="path/to/file"):
```
file_content
```
Description: This action will overwrite the file specified in the filepath field with the content wrapped in paired ``` symbols. Normally, you need to read the file before deciding to use EditFile to modify it.
Example: EditFile(filepath="hello_world.py"):
```
print("Hello, world!")
```
"""

    @classmethod
    def parse_action_from_text(cls, text: str) -> Optional[Action]:
        matches = re.findall(r'EditFile\(filepath=(.*?)\).*?```[ \t]*(\w+)?[ \t]*\r?\n(.*)[\r\n \t]*```', text, flags=re.DOTALL)
        if matches:
            filepath = matches[-1][0].strip()
            code = matches[-1][2].strip()
            return cls(code=code, filepath=remove_quote(filepath))
        return None    



@dataclass
class LOCAL_DB_SQL(Action):

    action_type: str = field(default="sql_command",init=False,repr=False,metadata={"help": 'type of action, c.f., "sql_command"'})
    code: str = field(metadata={"help": 'SQL command to execute'})
    file_path: str = field(default=None,metadata={"help": 'path to the database file'})
    output: str = field(default=None, metadata={"help": 'output file path or "direct"'})

    @classmethod
    def get_action_description(cls) -> str:
        return """
## SQL Action
* Signature: LOCAL_DB_SQL(file_path="database.sqlite", command="sql_command", output="path/to/output_file.csv" or "direct")
* Description: Executes an SQL command on the specified database file(SQLITE or Duckdb). If `output` is set to a file path, the results are saved to this CSV file; if set to 'direct', results are displayed directly.
* Examples:
  - Example1: LOCAL_DB_SQL(file_path="data.sqlite", command="SELECT name FROM sqlite_master WHERE type='table'", output="directly")
  - Example2: LOCAL_DB_SQL(file_path="data.sqlite", command="SELECT * FROM users", output="users_output.csv")
"""
    @classmethod
    def parse_action_from_text(cls, text: str) -> Optional[Action]:
        matches = re.findall(r'LOCAL_DB_SQL\(file_path=(.*?), command=(.*?), output=(.*?)\)', text, flags=re.DOTALL)
        if matches:
            file_path, command, output = (item.strip() for item in matches[-1])
            return cls(file_path=remove_quote(file_path), code=remove_quote(command), output=remove_quote(output))
        return None

    def __repr__(self) -> str:
        return f'{self.__class__.__name__}(file_path="{self.file_path}", command="{self.code}", output="{self.output}")'
    

@dataclass
class BIGQUERY_EXEC_SQL(Action):
    action_type: str = field(default="execute_bigquery_SQL",init=False,repr=False,metadata={"help": 'type of action, c.f., "exec_bq_sql"'})
    sql_query: str = field(metadata={"help": 'SQL query to execute'})
    is_save: bool = field(metadata={"help": 'whether to save result to CSV'})
    save_path: str = field(default=None, metadata={"help": 'path where the output CSV file is saved if is_save is True'})

    @classmethod
    def get_action_description(cls) -> str:
        return """
## BIGQUERY_EXEC_SQL Action
* Signature: BIGQUERY_EXEC_SQL(sql_query="SELECT * FROM your_table", is_save=True, save_path="/workspace/output_file.csv")
* Description: Executes a SQL query on Google Cloud BigQuery. If `is_save` is True, the results are saved to a specified CSV file; otherwise, results are printed.
If you estimate that the number of returned rows is small, you can set is_save=False, to directly view the results. If you estimate that the number of returned rows is large, be sure to set is_save = True.
The `save_path` CSV must be under the `/workspace` directory.
* Examples:
  - Example1: BIGQUERY_EXEC_SQL(sql_query="SELECT count(*) FROM sales", is_save=False)
  - Example2: BIGQUERY_EXEC_SQL(sql_query="SELECT user_id, sum(purchases) FROM transactions GROUP BY user_id", is_save=True, save_path="/workspace/result.csv")
"""

    @classmethod
    def parse_action_from_text(cls, text: str) -> Optional['BIGQUERY_EXEC_SQL']:
        pattern = r'BIGQUERY_EXEC_SQL\(sql_query=(?P<quote>\"\"\"|\"|\'|\"\"|\'\')(.*?)(?P=quote), is_save=(True|False)(, save_path=(?P<quote2>\"|\'|\"\"|\'\')(.*?)(?P=quote2))?\)'
        
        match = re.search(pattern, text, flags=re.DOTALL)
        if match:
            sql_query = match.group(2).strip()  # Capturing the SQL query part
            is_save = match.group(3).strip().lower() == 'true'  # Determining is_save
            save_path = match.group(6) if match.group(6) else ""  # Optional save_path handling
            
            return cls(sql_query=sql_query, is_save=is_save, save_path=save_path)
        return None



    def __repr__(self) -> str:
        save_info = f', save_path="{self.save_path}"' if self.is_save else ""
        return f'BIGQUERY_EXEC_SQL(sql_query="{self.sql_query}", is_save={self.is_save}{save_info})'



@dataclass
class SNOWFLAKE_EXEC_SQL(Action):
    action_type: str = field(default="execute_snowflake_SQL", init=False, repr=False, metadata={"help": 'type of action, c.f., "exec_sf_sql"'})
    sql_query: str = field(metadata={"help": 'SQL query to execute'})
    is_save: bool = field(metadata={"help": 'whether to save result to CSV'})
    save_path: str = field(default=None, metadata={"help": 'path where the output CSV file is saved if is_save is True'})

    @classmethod
    def get_action_description(cls) -> str:
        return """
## SNOWFLAKE_EXEC_SQL Action
* Signature: SNOWFLAKE_EXEC_SQL(sql_query="SELECT * FROM your_table", is_save=True, save_path="/workspace/output_file.csv")
* Description: Executes a SQL query on Snowflake. If `is_save` is True, the results are saved to a specified CSV file; otherwise, results are printed.
If you estimate that the number of returned rows is small, you can set is_save=False, to directly view the results. If you estimate that the number of returned rows is large, be sure to set is_save = True.
The `save_path` CSV must be under the `/workspace` directory.
* Examples:
  - Example1: SNOWFLAKE_EXEC_SQL(sql_query="SELECT count(*) FROM sales", is_save=False)
  - Example2: SNOWFLAKE_EXEC_SQL(sql_query="SELECT user_id, sum(purchases) FROM transactions GROUP BY user_id", is_save=True, save_path="/workspace/result.csv")
"""

    @classmethod
    def parse_action_from_text(cls, text: str) -> Optional['SNOWFLAKE_EXEC_SQL']:
        pattern = r'SNOWFLAKE_EXEC_SQL\(sql_query=(?P<quote>\"\"\"|\"|\'|\"\"|\'\')(.*?)(?P=quote), is_save=(True|False)(, save_path=(?P<quote2>\"|\'|\"\"|\'\')(.*?)(?P=quote2))?\)'
        
        match = re.search(pattern, text, flags=re.DOTALL)
        if match:
            sql_query = match.group(2).strip()  # Capturing the SQL query part
            is_save = match.group(3).strip().lower() == 'true'  # Determining is_save
            save_path = match.group(6) if match.group(6) else ""  # Optional save_path handling
            
            return cls(sql_query=sql_query, is_save=is_save, save_path=save_path)
        return None

    def __repr__(self) -> str:
        save_info = f', save_path="{self.save_path}"' if self.is_save else ""
        return f'SNOWFLAKE_EXEC_SQL(sql_query="{self.sql_query}", is_save={self.is_save}{save_info})'


    
    
    
@dataclass
class BQ_GET_TABLES(Action):

    action_type: str = field(default="get_tables",init=False,repr=False,metadata={"help": 'type of action, c.f., "get_tables"'})

    database_name: str = field(metadata={"help": 'Google Cloud project name'})

    dataset_name: str = field(metadata={"help": 'Dataset name within the project'})

    save_path: str = field(metadata={"help": 'path where the output CSV file is saved'})

    @classmethod
    def get_action_description(cls) -> str:
        return """
## GET_TABLES Action
* Signature: GET_TABLES(database_name="your_database_name", dataset_name="your_dataset_name", save_path="path/to/output_file.csv")
* Description: Executes a query to fetch all table names and their corresponding DDL from the specified dataset in Google Cloud BigQuery. The results are saved to the specified CSV file.
  - The BigQuery id of a table is usually in the form of database_name.dataset_name.table_name. This action mainly focuses on the tables under dataset_name.
* Examples:
  - Example1: GET_TABLES(database_name="bigquery-public-data", dataset_name="new_york", save_path="dataset_metadata.csv")
"""
    @classmethod
    def parse_action_from_text(cls, text: str) -> Optional[Action]:
        matches = re.findall(r'GET_TABLES\(database_name=(.*?), dataset_name=(.*?), save_path=(.*?)\)', text, flags=re.DOTALL)
        if matches:
            database_name, dataset_name, save_path = (item.strip() for item in matches[-1])
            return cls(database_name=remove_quote(database_name), dataset_name=remove_quote(dataset_name), save_path=remove_quote(save_path))
        return None

    def __repr__(self) -> str:
        return f'{self.__class__.__name__}(database_name="{self.database_name}", dataset_name="{self.dataset_name}", save_path="{self.save_path}")'
    
    
@dataclass
class BQ_GET_TABLE_INFO(Action):

    action_type: str = field(default="get_table_info",init=False,repr=False,metadata={"help": 'type of action, c.f., "get_table_info"'})

    database_name: str = field(metadata={"help": 'Google Cloud project name'})

    dataset_name: str = field(metadata={"help": 'Dataset name within the project'})

    table: str = field(metadata={"help": 'Name of the table to fetch information from'})

    save_path: str = field(metadata={"help": 'path where the output CSV file is saved'})

    @classmethod
    def get_action_description(cls) -> str:
        return """
## GET_TABLE_INFO Action
* Signature: GET_TABLE_INFO(database_name="your_database_name", dataset_name="your_dataset_name", table="table_name", save_path="path/to/output_file.csv")
* Description: Executes a query to fetch all column information (field path, data type, and description) from the specified table in the dataset in Google Cloud BigQuery. The results are saved to the specified CSV file.
 - The BigQuery id of a table is usually in the form of database_name.dataset_name.table_name.
* Examples:
  - Example1: GET_TABLE_INFO(database_name="bigquery-public-data", dataset_name="samples", table="shakespeare", save_path="shakespeare_info.csv")
"""
    @classmethod
    def parse_action_from_text(cls, text: str) -> Optional[Action]:
        matches = re.findall(r'GET_TABLE_INFO\(database_name=(.*?), dataset_name=(.*?), table=(.*?), save_path=(.*?)\)', text, flags=re.DOTALL)
        if matches:
            database_name, dataset_name, table, save_path = (item.strip() for item in matches[-1])
            return cls(database_name=remove_quote(database_name), dataset_name=remove_quote(dataset_name), table=remove_quote(table), save_path=remove_quote(save_path))
        return None

    def __repr__(self) -> str:
        return f'{self.__class__.__name__}(database_name="{self.database_name}", dataset_name="{self.dataset_name}", table="{self.table}", save_path="{self.save_path}")'


@dataclass
class BQ_SAMPLE_ROWS(Action):

    action_type: str = field(default="bq_sample_rows",init=False,repr=False,metadata={"help": 'type of action, c.f., "bq_sample_rows"'})

    database_name: str = field(metadata={"help": 'Google Cloud project name'})

    dataset_name: str = field(metadata={"help": 'Dataset name within the project'})

    table: str = field(metadata={"help": 'Name of the table to sample data from'})

    row_number: int = field(metadata={"help": 'Number of rows to sample'})

    save_path: str = field(metadata={"help": 'path where the output JSON file is saved'})

    @classmethod
    def get_action_description(cls) -> str:
        return """
## BQ_SAMPLE_ROWS Action
* Signature: BQ_SAMPLE_ROWS(database_name="your_database_name", dataset_name="your_dataset_name", table="table_name", row_number=3, save_path="path/to/output_file.json")
* Description: Executes a query to sample a specified number of rows from the table in the dataset in Google Cloud BigQuery using the TABLESAMPLE SYSTEM method. The results are saved in JSON format to the specified path.
* Examples:
  - Example1: BQ_SAMPLE_ROWS(database_name="bigquery-public-data", dataset_name="samples", table="shakespeare", row_number=3, save_path="shakespeare_sample_data.json")
"""
    @classmethod
    def parse_action_from_text(cls, text: str) -> Optional[Action]:
        matches = re.findall(r'BQ_SAMPLE_ROWS\(database_name=(.*?), dataset_name=(.*?), table=(.*?), row_number=(.*?), save_path=(.*?)\)', text, flags=re.DOTALL)
        if matches:
            database_name, dataset_name, table, row_number, save_path = (item.strip() for item in matches[-1])
            return cls(database_name=remove_quote(database_name), dataset_name=remove_quote(dataset_name), table=remove_quote(table), row_number=int(row_number), save_path=remove_quote(save_path))
        return None

    def __repr__(self) -> str:
        return f'{self.__class__.__name__}(database_name="{self.database_name}", dataset_name="{self.dataset_name}", table="{self.table}", row_number={self.row_number}, save_path="{self.save_path}")'
    


@dataclass
class Terminate(Action):

    action_type: str = field(
        default="terminate",
        init=False,
        repr=False,
        metadata={"help": "terminate action representing the task is finished, or you think it is impossible for you to complete the task"}
    )

    output: Optional[str] = field(
        default=None,
        metadata={"help": "answer to the task or output file path or 'FAIL', if exists"}
    )

    code : str = field(
        default=''
    )

    @classmethod
    def get_action_description(cls) -> str:
        return """
## Terminate Action
* Signature: Terminate(output="literal_answer_or_output_path")
* Description: This action denotes the completion of the entire task and returns the final answer or the output file/folder path. If the answer is a table, it must be saved in a CSV file, and you should tell me the file name. If the answer is not a table, just tell me the answer. Make sure the output file is located in the initial workspace directory. 
* Examples:
  - Example1: Terminate(output="New York")
  - Example2: Terminate(output="result.csv")
"""

    def __repr__(self) -> str:
        return f'{self.__class__.__name__}(output="{self.output}")'

    @classmethod
    def parse_action_from_text(cls, text: str) -> Optional[Action]:
        matches = re.findall(r'Terminate\(output=(.*?)\)', text, flags=re.DOTALL)
        if matches:
            output = matches[-1]
            return cls(output=remove_quote(output))
        return None
    

