# import debugpy; debugpy.connect(('127.0.0.1', 5688))
import json
import re
import pandas as pd
import math
import duckdb
from typing import List, Union
import os
import os.path as osp
import pandas as pd
import argparse
from google.cloud import bigquery
from google.cloud.bigquery import QueryJobConfig
import shutil
import sqlite3
from tqdm import tqdm
import signal
import snowflake.connector


# ---------- timeout --------------
class TimeoutException(Exception):
    pass

def timeout_handler(signum, frame):
    raise TimeoutException("Function execution time exceeded")

def run_with_timeout(func, timeout, *args, **kwargs):
    signal.signal(signal.SIGALRM, timeout_handler)
    signal.alarm(timeout)

    try:
        result = func(*args, **kwargs) 
        signal.alarm(0) 
        return result
    except TimeoutException:
        print(f"Function timed out after {timeout} seconds.")
        return None
    finally:
        signal.alarm(0) 
# ---------- timeout --------------


def load_jsonl_to_dict(jsonl_file):
    data_dict = {}
    with open(jsonl_file, 'r') as file:
        for line in file:
            item = json.loads(line.strip())
            instance_id = item['instance_id']
            data_dict[instance_id] = item
    return data_dict

def load_json_list_to_dict(json_file_path):
    with open(json_file_path, 'r', encoding='utf-8') as file:
        data_list = json.load(file)
    data_dict = {item['instance_id']: item for item in data_list}
    return data_dict


def compare_multi_pandas_table(pred, multi_gold, multi_condition_cols=[], multi_ignore_order=False):
    print('multi_condition_cols', multi_condition_cols)

    if multi_condition_cols == [] or multi_condition_cols == [[]] or multi_condition_cols == [None] or multi_condition_cols == None:
        multi_condition_cols = [[] for _ in range(len(multi_gold))]
    elif len(multi_gold) > 1 and not all(isinstance(sublist, list) for sublist in multi_condition_cols):
        multi_condition_cols = [multi_condition_cols for _ in range(len(multi_gold))]
    multi_ignore_order = [multi_ignore_order for _ in range(len(multi_gold))]

    for i, gold in enumerate(multi_gold):
        if compare_pandas_table(pred, gold, multi_condition_cols[i], multi_ignore_order[i]):
            return 1
    return 0
        
    
def compare_pandas_table(pred, gold, condition_cols=[], ignore_order=False):
    """_summary_

    Args:
        pred (Dataframe): _description_
        gold (Dataframe): _description_
        condition_cols (list, optional): _description_. Defaults to [].
        ignore_order (bool, optional): _description_. Defaults to False.

    """
    print('condition_cols', condition_cols)
    
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


def get_snowflake_sql_result(sql_query, is_save, save_dir=None, file_name="result.csv"):
    """
    is_save = True, output a 'result.csv'
    if_save = False, output a string
    """
    snowflake_credential = json.load(open('./credentials/snowflake_credential.json'))
    conn = snowflake.connector.connect(
        **snowflake_credential
    )
    cursor = conn.cursor()
    try:
        cursor.execute(sql_query)
        results = cursor.fetchall()
        columns = [desc[0] for desc in cursor.description]
        df = pd.DataFrame(results, columns=columns)
        if df.empty:
            print("No data found for the specified query.")
            results.to_csv(os.path.join(save_dir, file_name), index=False)
            return None, None
        else:
            if is_save:
                df.to_csv(os.path.join(save_dir, file_name), index=False)
                return None, None
    except Exception as e:
        print("Error occurred while fetching data: ", e)  
        return False, str(e)


def get_bigquery_sql_result(sql_query, is_save, credential_path, save_dir=None, file_name="result.csv", timeout=90):  
    """
    is_save = True, output a 'result.csv'
    if_save = False, output a string
    """
    os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = credential_path
    client = bigquery.Client()

    try:
        def execute_query():
            query_job = client.query(sql_query)
            return query_job.result().to_dataframe()
        
        results = run_with_timeout(execute_query, timeout)

        if results is None:
            print(f"Query timed out after {timeout} seconds.")
            return False, 'timed out'

        if results.empty:
            print("No data found for the specified query.")
            results.to_csv(os.path.join(save_dir, file_name), index=False)
            return None, None
        else:
            if is_save:
                results.to_csv(os.path.join(save_dir, file_name), index=False)
                return None, None
            else:
                value = results.iat[0, 0]
                return value, None
    except Exception as e:
        print("Error occurred while fetching data: ", e)  
        return False, str(e)
    return True, None
      

def get_sqlite_result(db_path, query, save_dir=None, file_name="result.csv", chunksize=500):
    conn = sqlite3.connect(db_path)
    memory_conn = sqlite3.connect(':memory:')

    conn.backup(memory_conn)
    
    try:
        if save_dir:
            if not os.path.exists(save_dir):
                os.makedirs(save_dir)
            for i, chunk in enumerate(pd.read_sql_query(query, memory_conn, chunksize=chunksize)):
                mode = 'a' if i > 0 else 'w'
                header = i == 0
                chunk.to_csv(os.path.join(save_dir, file_name), mode=mode, header=header, index=False)
        else:
            df = pd.read_sql_query(query, memory_conn)
            return True, df

    except Exception as e:
        print(f"An error occurred: {e}")
        return False, str(e)

    finally:
        memory_conn.close()
        conn.close()
    
    return True, None





if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Run evaluations for NLP models.")
    parser.add_argument("--mode", type=str, choices=["sql", "exec_result"], default='sql', help="Mode of submission results")
    parser.add_argument("--result_dir", type=str, default="spider2sql_example_submit_result", help="Result directory")
    parser.add_argument("--gold_dir", type=str, default="gold", help="Result directory")
    parser.add_argument("--is_sql_debug", action="store_true", default=False)
    parser.add_argument("--credential_path", type=str, default="./credentials/bigquery_credential2.json")
    args = parser.parse_args()
    
    if os.path.exists("temp"):
        shutil.rmtree("temp")
    os.makedirs("temp")

    
    evaluate_spider2sql(args)