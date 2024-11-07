import re
import pandas as pd
import math
import duckdb
from typing import List, Union
import os
import pandas as pd
from google.cloud import bigquery


def string_match(pred, gold, conj="or", exclude=[]):
    """

    Parameters:
    - pred (str): The string in which to search for substrings.
    - gold (list of str): A list of strings to be checked within the pred string.
    - conj (str): The conjunction to use for matching ('and' or 'or'). Defaults to 'or'. 
    - exclude (list of str): some string can't exist in the answer.

    Returns:
    - int: Returns 1 if the condition specified by 'conj' is met, otherwise returns 0.

    """
    
    if not isinstance(gold, list):
        gold = [gold]
    
    pred_lower = pred.lower()
    gold_lower = [sub.lower() for sub in gold]
    exclude_lower = [sub.lower() for sub in exclude]

    if any(sub in pred_lower for sub in exclude_lower):
        return 0  # Return 0 if any excluded items are found
    
    if conj == "or":
        # Check if any of the strings in 'gold_lower' are in 'pred_lower'
        return 1 if any(sub in pred_lower for sub in gold_lower) else 0
    elif conj == "and":
        # Check if all of the strings in 'gold_lower' are in 'pred_lower'
        return 1 if all(sub in pred_lower for sub in gold_lower) else 0
    else:
        raise ValueError("Invalid value for 'conj'. Choose 'and' or 'or'.")



def number_match(pred, gold, percentage=False, precision=4, conj="or"):
    """
    Parameters:
    - pred (str): The string in which to search for substrings.
    - gold (list[str|float] of str): A list of string/numbers to be checked within the pred string.
    - percentage (bool): default false. if the gold answer is related with "percentage", set it as true to make the evaluation robust.
    - precision: Decimal places
    - conj (str): The conjunction to use for matching ('and' or 'or'). Defaults to 'or'. Most time is 'or'
    
    """
    
    import regex

    def extract_numbers(input_string):
        """
        Extracts all numbers from a given string including integers, floating-point numbers,
        numbers with commas, and percentages, returning them as a list of strings in their
        original numeric format. This function correctly includes the percentage symbol if present.
        """
        number_pattern = r'\b\d{1,3}(?:,\d{3})*\b(?:\.\d+)?%?|\b\d+\b(?:\.\d+)?%?'
        matches = regex.findall(number_pattern, input_string)
        return matches

    def convert_to_float(value):
        """
        Convert string to float, removing commas and handling percentages if specified.
        Converts percentages by dividing the number by 100.
        """
        value = str(value).replace(',', '')  # Ensure value is treated as a string
        if '%' in value:
            value = value.replace('%', '')
            return float(value) / 100
        return float(value)
    
    
    def is_within_precision(converted_pred_numbers, gold_value, precision):
        """
        Checks if any number in converted_pred_numbers is within a specified precision of gold_value.
        """
        return any(abs(num - gold_value) <= 10 ** (-precision) for num in converted_pred_numbers)

    pred_numbers = extract_numbers(pred)


    if (isinstance(gold,(str,float)) or (isinstance(gold, list)  and len(gold)==1 )) and len(pred_numbers)!=1:
        return 0
    converted_pred_numbers = [convert_to_float(num) for num in pred_numbers]
    gold = [convert_to_float(g) for g in (gold if isinstance(gold, list) else [gold])]
    
    if percentage:
        gold = [y for x in gold for y in (x, x * 100)]

    if conj == "and":
        return 1 if all(is_within_precision(converted_pred_numbers, gold_value, precision) for gold_value in gold) else 0
    elif conj == "or":
        return 1 if any(is_within_precision(converted_pred_numbers, gold_value, precision) for gold_value in gold) else 0
    else:
        raise ValueError(f"Invalid value for 'conj'. Choose 'and' or 'or'. Received: {conj}")
    


    

def compare_pandas_table(pred, gold, condition_cols=[], ignore_order=False):
    
    tolerance = 1e-3

    def vectors_match(v1, v2, tol=tolerance, ignore_order_=False):
        if ignore_order_:
            v1, v2 = (sorted(v1, key=lambda x: (x is None, str(x), isinstance(x, (int, float)))),
                    sorted(v2, key=lambda x: (x is None, str(x), isinstance(x, (int, float)))))
        if len(v1) != len(v2):
            return False
        for a, b in zip(v1, v2):
            if pd.isna(a) and pd.isna(b):
                continue
            elif isinstance(a, (int, float)) and isinstance(b, (int, float)):
                if not math.isclose(float(a), float(b), abs_tol=tol):
                    return False
            elif a != b:
                return False
        return True
    
    if condition_cols != []:
        gold_cols = gold.iloc[:, condition_cols]
    else:
        gold_cols = gold
    pred_cols = pred
    
    t_gold_list = gold_cols.transpose().values.tolist()
    t_pred_list = pred_cols.transpose().values.tolist()
    score = 1
    for _, gold in enumerate(t_gold_list):
        if not any(vectors_match(gold, pred, ignore_order_=ignore_order) for pred in t_pred_list):
            score = 0
        else:
            for j, pred in enumerate(t_pred_list):
                if vectors_match(gold, pred, ignore_order_=ignore_order):
                    break

    return score
    

def compare_multi_pandas_table(pred, multi_gold, multi_condition_cols=[], multi_ignore_order=False):
    if multi_condition_cols == [] or multi_condition_cols == [[]] or multi_condition_cols == [None] or multi_condition_cols == None:
        multi_condition_cols = [[] for _ in range(len(multi_gold))]
    multi_ignore_order = [multi_ignore_order for _ in range(len(multi_gold))]
    
    for i, gold in enumerate(multi_gold):
        if compare_pandas_table(pred, gold, multi_condition_cols[i], multi_ignore_order[i]):
            return 1
    return 0


def table_match(result: str, gold, condition_cols=[], ignore_order=False) -> float:
    """ 
    @args:
        result (str):
        gold (str|List):
        condition_cols (List[int])
        ignore_order (bool)
    """
    df1 = pd.read_csv(result, low_memory=False)
    
    if isinstance(gold, str):
        df2 = pd.read_csv(gold, low_memory=False)
        score = compare_pandas_table(df1, df2, condition_cols=condition_cols, ignore_order=ignore_order)
    elif isinstance(gold, List):
        df_list = [pd.read_csv(g, low_memory=False) for g in gold]
        score = compare_multi_pandas_table(df1, df_list, multi_condition_cols=condition_cols, multi_ignore_order=ignore_order)
    
    return score



def duckdb_match(result: str, gold: str, condition_tabs=None, condition_cols: List[List[int]]=None, ignore_orders: List[bool]=None):
    """
    Parameters:
    - result (str): Path to the DuckDB file containing the result tables.
    - gold (str): Path to the DuckDB file containing the gold standard tables.
    - condition_tabs (List[str], optional): List of table names to be checked. If not provided, all tables in the gold DuckDB file will be considered.
    - condition_cols (List[List[int]], optional): A list of lists, where each inner list contains column indices used for matching conditions for the corresponding table. Defaults to considering all columns.
    - ignore_orders (List[bool], optional): A list of boolean values indicating whether to ignore the row order for each table comparison. Defaults to [False] for each table.
    """
   
   
    def get_duckdb_table_names(db: str) -> List[str]:
        """
        Retrieves the names of all tables in the DuckDB database.

        Parameters:
        - db (str): The path to the DuckDB database file.

        Returns:
        - List[str]: A list of table names in the DuckDB database.
        """
        con = duckdb.connect(database=db, read_only=True)
        result = con.execute("SHOW TABLES").fetchall()
        con.close()
        return [row[0] for row in result]
    
    
    def get_duckdb_pandas_table(db, table_name):
        con = duckdb.connect(database=db, read_only=True)
        df = con.execute(f'SELECT * FROM {table_name}').fetchdf()
        con.close()
        return df
    
    if condition_tabs is None:
        condition_tabs = get_duckdb_table_names(gold)

    gold_tables = [get_duckdb_pandas_table(gold, table_name) for table_name in condition_tabs]
    try:
        pred_tables = [get_duckdb_pandas_table(result, table_name) for table_name in condition_tabs]
    except:
        return 0
    
    assert len(gold_tables) == len(pred_tables)

    if ignore_orders is None:
        ignore_orders = [False] * len(gold_tables)
        
    assert len(ignore_orders) == len(gold_tables)

    if condition_cols is None:
        condition_cols = [[]] * len(gold_tables)


    assert len(condition_cols) == len(gold_tables)
    
    for i, (gold_table, pred_table) in enumerate(zip(gold_tables, pred_tables)):
        if not compare_pandas_table(pred_table, gold_table, condition_cols=condition_cols[i], ignore_order=ignore_orders[i]):
            return 0
        
    return 1


def tables_match(result: List[str], gold: List[str], condition_cols: List[List[int]]=None, ignore_orders: List[bool]=None):
    """
    Parameters:
    - result (Lstr): Path to the result tables.
    - gold (str): Path to the gold standard tables.
    - condition_cols (List[List[int]], optional): A list of lists, where each inner list contains column indices used for matching conditions for the corresponding table. Defaults to considering all columns.
    - ignore_orders (List[bool], optional): A list of boolean values indicating whether to ignore the row order for each table comparison. Defaults to [False] for each table.
    """

    def get_tables_to_dfs(csv_file: str):
        df = pd.read_csv(csv_file)
        return df

    gold_tables = [get_tables_to_dfs(table_name) for table_name in gold]
    try:
        pred_tables = [get_tables_to_dfs(table_name) for table_name in result]
    except:
        return 0
    
    assert len(gold_tables) == len(pred_tables)

    if ignore_orders is None:
        ignore_orders = [False] * len(gold_tables)
        
    assert len(ignore_orders) == len(gold_tables)

    if condition_cols is None:
        condition_cols = [[]] * len(gold_tables)


    assert len(condition_cols) == len(gold_tables)
    
    for i, (gold_table, pred_table) in enumerate(zip(gold_tables, pred_tables)):
        if not compare_pandas_table(pred_table, gold_table, condition_cols=condition_cols[i], ignore_order=ignore_orders[i]):
            return 0
        
    return 1

    
    
def get_bigquery_sql_result(sql_query, is_save, save_dir=None, save_file="result.csv"):
    """
    is_save = True, output a 'result.csv'
    if_save = False, output a string
    """
    os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "./credentials/bigquery_credential.json"
    client = bigquery.Client()
    query_job = client.query(sql_query)
    try:
      results = query_job.result().to_dataframe() 
      if results.empty:
        print("No data found for the specified query.")
      else:
        if is_save:
            results.to_csv(os.path.join(save_dir, save_file), index=False)
            return None
        else:
            value = results.iat[0, 0]
            return value
    except Exception as e:
      print("Error occurred while fetching data: ", e)
    
    
    
def execute_process(eval_func, eval_metadata_parameters, gold_dir, file_name="result.csv"):
    
    sql_query = open(os.path.join(gold_dir, "gold.sql"), 'r', encoding='utf-8').read()
    if eval_func in ["number_match", "string_match"]:
        answer = get_bigquery_sql_result(sql_query=sql_query, is_save=False)
        eval_metadata_parameters["gold"] = answer
    elif eval_func == "table_match":
        answer = get_bigquery_sql_result(sql_query=sql_query, is_save=True, save_dir=gold_dir, save_file=file_name)
        eval_metadata_parameters["gold"] = file_name
    
    return eval_metadata_parameters
        
        

if __name__ == "__main__":
    
    
    eval_metadata = """
        {
            "func": "table_match", 
            "temporal": true, 
            "parameters": {
                
            }
        }
    """
    eval_json = json.loads(eval_metadata)
    eval_metadata = execute_process(eval_json["func"], eval_json["parameters"], "/Users/leifangyu/workspace/Spider2-C/Spider2-C/evaluation_suite/gold/335fb285-c9fd-45ff-ba8d-fe89a62016f7")

    print(eval_metadata)


    # eval_json = json.loads(eval_metadata)
    # import pdb; pdb.set_trace()
    # answer = get_bigquery_sql_result(eval_json["func"], gold_sql, eval_json["parameters"])
    # print(answer)
    
    # eval_metadata = """
    #     {
    #         "func": "table_match",
    #         "parameters": {
    #             "gold": "./gold/1d009ac3-1c75-447b-a7e0-49ccc2b5fbf9/result.csv",
    #             "condition_cols": [1],
    #             "ignore_order": true
    #         }
    #     }
    # """
    
    
    # eval_metadata = """
    #     {
    #         "func": "number_match",
    #         "parameters": {
    #             "gold": ["Google 24oz Ring Bottle Blue"],
    #             "exclude": []
    #         }
    #     }
    # """
    
    # eval_metadata = """
    #     {
    #         "func": "number_match",
    #         "parameters": {
    #             "gold": ["17.5056918795%"],
    #             "percentage": true
    #         }
    #     }
    # """
    
    
    # eval_metadata = """
    #     {
    #         "func": "number_match",
    #         "parameters": {
    #             "gold": 
    #         }
    #     }
    # """
