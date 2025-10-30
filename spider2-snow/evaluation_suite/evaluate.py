import json
import re
import math
from typing import List, Union
import os
import os.path as osp
import argparse
import pandas as pd
from google.cloud import bigquery
import shutil
import sqlite3
from tqdm import tqdm
import snowflake.connector
import logging
import threading
from concurrent.futures import ThreadPoolExecutor, as_completed
from threading import Lock
import signal
import time
import tempfile
from pathlib import Path
from functools import lru_cache

import sys
class TeeOutput:
    def __init__(self, filename):
        self.console = sys.stdout
        self.file = open(filename, 'w')
        self.lock = Lock()
    
    def write(self, message):
        with self.lock:
            self.console.write(message)
            self.file.write(message)
    
    def flush(self):
        with self.lock:
            self.console.flush()
            self.file.flush()
    
    def close(self):
        self.file.close()

sys.stdout = TeeOutput('log.txt')
sys.stderr = sys.stdout

TOTAL_GB_PROCESSED = 0.0
GB_LOCK = Lock()  

byte_output_dict = {}

@lru_cache(maxsize=None)
def load_gold_csv(file_path: str) -> pd.DataFrame:
    """Cache gold CSV loads to avoid repeated disk reads during evaluation."""
    return pd.read_csv(file_path)

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
    # print('multi_condition_cols', multi_condition_cols)

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
    # print('condition_cols', condition_cols)
    
    tolerance = 1e-2

    def normalize(value):
        if pd.isna(value):
            return 0
        return value

    def vectors_match(v1, v2, tol=tolerance, ignore_order_=False):
        v1 = [normalize(x) for x in v1]
        v2 = [normalize(x) for x in v2]
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
        if not isinstance(condition_cols, (list, tuple)):
            condition_cols = [condition_cols]
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



def get_snowflake_sql_result(sql_query, database_id, is_save, save_dir=None, file_name="result.csv", timeout=30, instance_id=None):
    snowflake_credential = json.load(open('snowflake_credential.json'))
    connection_kwargs = {k: v for k, v in snowflake_credential.items() if k != "session_parameters"}
    session_parameters = snowflake_credential.get("session_parameters", {}).copy()
    session_parameters["STATEMENT_TIMEOUT_IN_SECONDS"] = timeout
    connection_kwargs["session_parameters"] = session_parameters

    conn = snowflake.connector.connect(
        database=database_id,
        **connection_kwargs
    )
    cursor = conn.cursor()
    
    prefix = f"[{instance_id}] " if instance_id else ""

    try:
        cursor.execute(sql_query)
        results = cursor.fetchall()
        columns = [desc[0] for desc in cursor.description]
        df = pd.DataFrame(results, columns=columns)
        if df.empty:
            message = "No data found for the specified query."
            print(f"{prefix}{message}")
            return False, message
        else:
            if is_save:
                df.to_csv(os.path.join(save_dir, file_name), index=False)
                return True, None
    except snowflake.connector.errors.ProgrammingError as e:
        error_message = str(e)
        if "STATEMENT_TIMEOUT" in error_message or "SQL execution canceled" in error_message:
            timeout_msg = f"Query execution timed out after {timeout} seconds"
            print(f"{prefix}{timeout_msg}")
            return False, timeout_msg
        print(f"{prefix}Error occurred while fetching data: {error_message}")
        return False, error_message
    except Exception as e:
        error_message = str(e)
        print(f"{prefix}Error occurred while fetching data: {error_message}")
        return False, error_message
    finally:
        cursor.close()
        conn.close()


import re

def extract_sql_query(pred_sql_query):
    pattern = r'```sql\n(.*?)\n```'
    match = re.search(pattern, pred_sql_query, re.DOTALL)
    
    if match:
        return match.group(1).strip()
    return pred_sql_query



def evaluate_single_sql_instance(
    id,
    eval_standard_dict,
    spider2sql_metadata,
    pred_result_dir,
    gold_sql_dir,
    gold_result_dir,
    temp_dir,
    result_csv_dir=None,
    timeout=30,
):
    error_info = None
    
    try:
        pred_sql_query = open(os.path.join(pred_result_dir, f"{id}.sql")).read()

        pred_sql_query = extract_sql_query(pred_sql_query)
        
        thread_temp_dir = os.path.join(temp_dir, f"thread_{threading.current_thread().ident}")
        os.makedirs(thread_temp_dir, exist_ok=True)
        
            
        if id.startswith("sf"):
            database_id = spider2sql_metadata[id]['db_id']
            exe_flag, dbms_error_info = get_snowflake_sql_result(
                pred_sql_query,
                database_id,
                True,
                thread_temp_dir,
                f"{id}.csv",
                timeout=timeout,
                instance_id=id,
            )  
            if exe_flag == False: 
                score = 0
                error_info = dbms_error_info
            else:                    
                pred_pd = pd.read_csv(os.path.join(thread_temp_dir, f"{id}.csv"))  
                
                if result_csv_dir:
                    shutil.copy2(os.path.join(thread_temp_dir, f"{id}.csv"), 
                               os.path.join(result_csv_dir, f"{id}.csv"))
                
                if '_' in id:
                    pattern = re.compile(rf'^{re.escape(id)}(_[a-z])?\.csv$')
                else:
                    pattern = re.compile(rf'^{re.escape(id)}(_[a-z])?\.csv$')
                    
                all_files = os.listdir(gold_result_dir)
                csv_files = [file for file in all_files if pattern.match(file)]
                csv_files = sorted(csv_files)
                base_file_path = os.path.join(gold_result_dir, f"{id}.csv")
                if os.path.exists(base_file_path):
                    try:
                        gold_pd = load_gold_csv(base_file_path)
                        score = compare_pandas_table(
                            pred_pd,
                            gold_pd,
                            eval_standard_dict.get(id)['condition_cols'],
                            eval_standard_dict.get(id)['ignore_order'],
                        )
                    except Exception as e:
                        print(f"{id}: compare against {base_file_path} failed: {e}")
                        score = 0
                        error_info = 'Python Script Error:' + str(e)
                    if score == 0 and error_info is None:
                        error_info = 'Result Error'     
                elif csv_files:
                    try:
                        csv_file_paths = [os.path.join(gold_result_dir, file) for file in csv_files]
                        gold_pds = [load_gold_csv(file_path) for file_path in csv_file_paths]
                        score = compare_multi_pandas_table(
                            pred_pd,
                            gold_pds,
                            eval_standard_dict.get(id)['condition_cols'],
                            eval_standard_dict.get(id)['ignore_order'],
                        )
                    except Exception as e:
                        print(f"{id}: multi-compare against {csv_file_paths} failed: {e}")
                        score = 0
                        error_info = 'Python Script Error:' + str(e)
                    if score == 0 and error_info is None:
                        error_info = 'Result Error'
                else:
                    score = 0
                    if error_info is None:
                        error_info = 'No matching gold file found'
                        
    except Exception as e:
        print(f"Error evaluating {id}: {e}")
        score = 0
        error_info = f"Evaluation Error: {str(e)}"
        pred_sql_query = ""
    
    return {
        "instance_id": id, 
        "score": score,
        "pred_sql": pred_sql_query,
        "error_info": error_info
    }


def evaluate_single_exec_result_instance(id, eval_standard_dict, pred_result_dir, gold_result_dir):
    # print(f">>>Evaluating {id}...")
    error_info = None
    
    try:
        pred_pd = pd.read_csv(os.path.join(pred_result_dir, f"{id}.csv"))
        
        if '_' in id:
            pattern = re.compile(rf'^{re.escape(id)}(_[a-z])?\.csv$')
        else:
            pattern = re.compile(rf'^{re.escape(id)}(_[a-z])?\.csv$')
            
        all_files = os.listdir(gold_result_dir)
        csv_files = [file for file in all_files if pattern.match(file)]
        csv_files = sorted(csv_files)
        
        base_file_path = os.path.join(gold_result_dir, f"{id}.csv")
        if os.path.exists(base_file_path):
            try:
                gold_pd = load_gold_csv(base_file_path)
                score = compare_pandas_table(
                    pred_pd,
                    gold_pd,
                    eval_standard_dict.get(id)['condition_cols'],
                    eval_standard_dict.get(id)['ignore_order'],
                )
            except Exception as e:
                print(f"{id}: compare against {base_file_path} failed: {e}")
                score = 0
                error_info = 'Python Script Error:' + str(e)
            if score == 0 and error_info is None:
                error_info = 'Result Error'
                
        elif csv_files:
            try:
                csv_file_paths = [os.path.join(gold_result_dir, file) for file in csv_files]
                gold_pds = [load_gold_csv(file_path) for file_path in csv_file_paths]
                score = compare_multi_pandas_table(
                    pred_pd,
                    gold_pds,
                    eval_standard_dict.get(id)['condition_cols'],
                    eval_standard_dict.get(id)['ignore_order'],
                )
            except Exception as e:
                print(f"{id}: multi-compare against {csv_file_paths} failed: {e}")
                score = 0
                error_info = 'Python Script Error:' + str(e)
            if score == 0 and error_info is None:
                error_info = 'Result Error'
        else:
            score = 0
            error_info = 'No matching gold file found'
            
    except Exception as e:
        print(f"{id} ERROR!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! {e}")
        score = 0
        error_info = f"Evaluation Error: {str(e)}"
    
    return {
        "instance_id": id, 
        "score": score,
        "pred_sql": None,
        "error_info": error_info
    }


def save_correct_ids_to_csv(output_results, result_dir):
    correct_ids = [item['instance_id'] for item in output_results if item['score'] == 1]
    
    df = pd.DataFrame({'output': correct_ids})
    
    parent_dir = os.path.dirname(result_dir)
    result_dir_name = os.path.basename(result_dir)
    csv_file_path = os.path.join(parent_dir, f"{result_dir_name}.csv")
    
    df.to_csv(csv_file_path, index=False)
    print(f"Correct IDs saved to: {csv_file_path}")
    
    return csv_file_path


def evaluate_spider2sql(args, temp_dir: Path):
    mode = args.mode
    gold_sql_dir = os.path.join(args.gold_dir, "sql")
    gold_result_dir = os.path.join(args.gold_dir, "exec_result")
    pred_result_dir = args.result_dir
    
    eval_standard_dict = load_jsonl_to_dict(os.path.join(args.gold_dir, "spider2snow_eval.jsonl"))
    spider2sql_metadata = load_jsonl_to_dict("../spider2-snow.jsonl")
    
    result_csv_dir = None
    if mode == "sql":
        result_csv_dir = f"{pred_result_dir}_csv"
        if os.path.exists(result_csv_dir):
            shutil.rmtree(result_csv_dir)
        os.makedirs(result_csv_dir)
    
    gold_ids = []
    pred_ids = []
    if mode == "sql":
        for file in os.listdir(args.result_dir):
            if file.endswith(".sql"):
                pred_ids.append(file.split(".")[0])
    elif mode == 'exec_result':
        for file in os.listdir(args.result_dir):
            if file.endswith(".csv"):
                pred_ids.append(file.split(".")[0])
                       
    gold_ids = list(eval_standard_dict.keys())
    eval_ids = list(set(gold_ids).intersection(pred_ids))
    eval_ids = sorted(eval_ids)  # sorted, for reproduce result
    
    output_results = []
    max_workers = min(args.max_workers if hasattr(args, 'max_workers') else 8, len(eval_ids))

    if mode == "sql":
        with ThreadPoolExecutor(max_workers=max_workers) as executor:
            future_to_id = {
                executor.submit(
                    evaluate_single_sql_instance, 
                    id, 
                    eval_standard_dict, 
                    spider2sql_metadata, 
                    pred_result_dir, 
                    gold_sql_dir, 
                    gold_result_dir,
                    temp_dir=str(temp_dir),
                    result_csv_dir=result_csv_dir,
                    timeout=args.timeout,
                ): id for id in eval_ids
            }
            
            for future in tqdm(as_completed(future_to_id), total=len(eval_ids), desc="Evaluating SQL"):
                result = future.result()
                output_results.append(result)
    
    elif mode == "exec_result":
        with ThreadPoolExecutor(max_workers=max_workers) as executor:
            future_to_id = {
                executor.submit(
                    evaluate_single_exec_result_instance,
                    id,
                    eval_standard_dict,
                    pred_result_dir,
                    gold_result_dir
                ): id for id in eval_ids
            }
            
            for future in tqdm(as_completed(future_to_id), total=len(eval_ids), desc="Evaluating Exec Results"):
                result = future.result()
                output_results.append(result)

    print({item['instance_id']: item['score'] for item in output_results})  
    correct_examples = sum([item['score'] for item in output_results]) 

    print(f"Final score: {correct_examples / len(output_results)}, Correct examples: {correct_examples}, Total examples: {len(output_results)}")
    print(f"Real score: {correct_examples / 547}, Correct examples: {correct_examples}, Total examples: 547")
    
    if mode == "sql" and result_csv_dir:
        print(f"Execution results saved to: {result_csv_dir}")
    
    csv_file_path = save_correct_ids_to_csv(output_results, pred_result_dir)



if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Run evaluations for NLP models.")
    parser.add_argument("--mode", type=str, choices=["sql", "exec_result"], default='sql', help="Mode of submission results")
    parser.add_argument("--result_dir", type=str, default="spider2sql_example_submit_result", help="Result directory")
    parser.add_argument("--gold_dir", type=str, default="gold", help="Result directory")
    parser.add_argument("--is_sql_debug", action="store_true", default=False)
    parser.add_argument("--max_workers", type=int, default=20, help="Maximum number of worker threads")
    parser.add_argument("--timeout", type=int, default=60, help="SQL execution timeout in seconds")
    parser.add_argument(
        "--temp_dir",
        type=str,
        default=None,
        help="Optional working directory for temporary files. Defaults to a unique directory per run.",
    )
    args = parser.parse_args()
    
    auto_temp = False
    if args.temp_dir:
        temp_path = Path(args.temp_dir).expanduser().resolve()
        if temp_path.exists():
            shutil.rmtree(temp_path)
        temp_path.mkdir(parents=True, exist_ok=True)
    else:
        temp_path = Path(tempfile.mkdtemp(prefix="evaluate_"))
        auto_temp = True
    
    try:
        evaluate_spider2sql(args, temp_path)
    finally:
        if auto_temp:
            shutil.rmtree(temp_path, ignore_errors=True)
