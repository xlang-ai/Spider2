# import debugpy; debugpy.connect(('127.0.0.1', 5690))
import time
from multiprocessing import Pool, set_start_method
import json
import re
import pandas as pd
import math
import duckdb
from typing import List, Union
import os
import os.path as osp
import argparse
from google.cloud import bigquery
import shutil
import sqlite3
from tqdm import tqdm
from evaluate_utils import compare_pandas_table, compare_multi_pandas_table, load_jsonl_to_dict, load_json_list_to_dict, get_bigquery_sql_result, get_sqlite_result, get_snowflake_sql_result


def evaluate_instance(id, mode, pred_result_dir, gold_result_dir, gold_sql_dir, eval_standard_dict, spider2sql_metadata, credential_path, eval_result_dir):
    """Function to evaluate each instance, to be executed in parallel."""
    print(f">>>Evaluating {id}...")

    error_info = None
    assert mode == "sql"
    pred_sql_files = [f for f in os.listdir(pred_result_dir) if f.startswith(f"{id}@") and f.endswith(".sql")]
    instance_correct = False
    error_info = None

    for pred_sql_file in pred_sql_files:
        # score = 0
        pred_sql_query = open(os.path.join(pred_result_dir, pred_sql_file)).read()
        if id.startswith("bq") or id.startswith("ga"):
            query_s_time = time.time()            
            exe_flag, dbms_error_info = get_bigquery_sql_result(pred_sql_query, True, credential_path, "temp", f"{id}_pred.csv")
            query_e_time = time.time()
            print(f">>>for id: {id}, Query time: {query_e_time - query_s_time}")
            if exe_flag == False:
                score = 0
                error_info = dbms_error_info
            else:
                resultEq_s_time = time.time()
                pred_pd = pd.read_csv(os.path.join("temp", f"{id}_pred.csv"))
                pattern = re.compile(rf'^{re.escape(id)}(_[a-z])?\.csv$')

                if 'temporal' in eval_standard_dict[id] and eval_standard_dict[id]['temporal']:
                    gold_sql_query = open(os.path.join(gold_sql_dir, f"{id}.sql")).read()
                    exe_flag, dbms_error_info = get_bigquery_sql_result(gold_sql_query, True, credential_path, "temp", f"{id}_gold.csv")
                    if exe_flag == False:
                        score = 0
                        error_info = dbms_error_info
                    else:
                        gold_pd = pd.read_csv(os.path.join("temp", f"{id}_gold.csv"))
                        score = compare_pandas_table(pred_pd, gold_pd, eval_standard_dict[id]['condition_cols'], eval_standard_dict[id]['ignore_order'])
                else:
                    all_files = os.listdir(gold_result_dir)
                    csv_files = [file for file in all_files if pattern.match(file)]
                    if len(csv_files) == 1:
                        gold_pd = pd.read_csv(os.path.join(gold_result_dir, f"{id}.csv"))
                        try:
                            score = compare_pandas_table(pred_pd, gold_pd, eval_standard_dict[id]['condition_cols'], eval_standard_dict[id]['ignore_order'])
                        except Exception as e:
                            # print(f"An error occurred: {e}")
                            score = 0
                            error_info = 'Python Script Error:' + str(e)
                        if score == 0 and error_info is None:
                            error_info = 'Result Error'
                    elif len(csv_files) > 1:
                        gold_pds = [pd.read_csv(os.path.join(gold_result_dir, file)) for file in csv_files]
                        score = compare_multi_pandas_table(pred_pd, gold_pds, eval_standard_dict[id]['condition_cols'], eval_standard_dict[id]['ignore_order'])
                        if score == 0 and error_info is None:
                            error_info = 'Result Error'
                resultEq_e_time = time.time()
                # print(f">>>for id: {id}, ResultEq time: {resultEq_e_time - resultEq_s_time}")

            try:
                if score == 1:
                    instance_correct = True
                    break
            except Exception as e:
                print(f"warning: score is not defined! This is because the missing csv for {id} in gold_result_dir. Please check!!")
                

        elif id.startswith("local"):
            query_s_time = time.time()
            exe_flag, dbms_error_info = get_sqlite_result(f"../resource/databases/spider2-localdb/{spider2sql_metadata.get(id)['db']}.sqlite", pred_sql_query, "temp", f"{id}_pred.csv")
            query_e_time = time.time()
            print(f">>>for id: {id}, Query time: {query_e_time - query_s_time}")
            if exe_flag == False:
                score = 0
                error_info = dbms_error_info
            else:

                resultEq_s_time = time.time()
                pred_pd = pd.read_csv(os.path.join("temp", f"{id}_pred.csv"))
                pattern = re.compile(rf'^{re.escape(id)}(_[a-z])?\.csv$')

                all_files = os.listdir(gold_result_dir)
                csv_files = [file for file in all_files if pattern.match(file)]
                if len(csv_files) == 1:
                    gold_pd = pd.read_csv(os.path.join(gold_result_dir, f"{id}.csv"))
                    try:
                        score = compare_pandas_table(pred_pd, gold_pd, eval_standard_dict[id]['condition_cols'], eval_standard_dict[id]['ignore_order'])
                    except Exception as e:
                        # print(f"An error occurred: {e}")
                        score = 0
                        error_info = 'Python Script Error:' + str(e)
                    if score == 0 and error_info is None:
                        error_info = 'Result Error'
                elif len(csv_files) > 1:
                    gold_pds = [pd.read_csv(os.path.join(gold_result_dir, file)) for file in csv_files]
                    score = compare_multi_pandas_table(pred_pd, gold_pds, eval_standard_dict[id]['condition_cols'], eval_standard_dict[id]['ignore_order'])
                    if score == 0 and error_info is None:
                        error_info = 'Result Error'

            if score == 1:
                instance_correct = True
                break
        
        elif id.startswith("sf"):
            query_s_time = time.time()
            exe_flag, dbms_error_info = get_snowflake_sql_result(pred_sql_query, True, "temp", f"{id}_pred.csv")  
            query_e_time = time.time()
            print(f">>>for id: {id}, Query time: {query_e_time - query_s_time}")
            if exe_flag == False: 
                score = 0
                error_info = dbms_error_info
            else:                    
                pred_pd = pd.read_csv(os.path.join("temp", f"{id}_pred.csv"))  
                if '_' in id:
                    pattern = re.compile(rf'^{re.escape(id)}(_[a-z])?\.csv$')
                else:
                    pattern = re.compile(rf'^{re.escape(id)}(_[a-z])?\.csv$')
                    
                if 'temporal' in eval_standard_dict[id] and eval_standard_dict[id]['temporal']:
                    gold_sql_query = open(os.path.join(gold_sql_dir, f"{id}.sql")).read()
                    exe_flag, dbms_error_info = get_snowflake_sql_result(gold_sql_query, True, "temp", f"{id}_gold.csv")
                    if exe_flag == False: 
                        score = 0
                        error_info = dbms_error_info
                    else:
                        gold_pd = pd.read_csv(os.path.join("temp", f"{id}_gold.csv"))
                        score = compare_pandas_table(pred_pd, gold_pd, eval_standard_dict.get(id)['condition_cols'], eval_standard_dict.get(id)['ignore_order'])
                else:
                    all_files = os.listdir(gold_result_dir)
                    csv_files = [file for file in all_files if pattern.match(file)]
                    if len(csv_files) == 1:
                        gold_pd = pd.read_csv(os.path.join(gold_result_dir, f"{id}.csv"))
                        try:
                            score = compare_pandas_table(pred_pd, gold_pd, eval_standard_dict.get(id)['condition_cols'], eval_standard_dict.get(id)['ignore_order'])
                        except Exception as e:
                            print(f"An error occurred: {e}")
                            score = 0
                            error_info = 'Python Script Error:' + str(e)
                        if score == 0 and error_info is None:
                            error_info = 'Result Error'     
                    elif len(csv_files) > 1:
                        gold_pds = [pd.read_csv(os.path.join(gold_result_dir, file)) for file in csv_files]
                        score = compare_multi_pandas_table(pred_pd, gold_pds, eval_standard_dict.get(id)['condition_cols'], eval_standard_dict.get(id)['ignore_order'])
                        if score == 0 and error_info is None:
                            error_info = 'Result Error'  

            if score == 1:
                instance_correct = True
                break                           

    # with open(f"{id}.txt", "w") as f:
    #     f.write("")

    try:
        query_time = query_e_time - query_s_time
    except:
        query_time = None

    eval_result = {
        "instance_id": id, 
        "score": 1 if instance_correct else 0,
        "pred_sql": pred_sql_query,  # the last examined sql
        "error_info": error_info,  # the last error info
        "query_time": query_time
    }

    with open(osp.join(eval_result_dir, f"{id}.json"), 'w') as f:
        json.dump(eval_result, f, indent=4)
    return eval_result


def get_score(final_results):
    toks_data = {}
    with open('./gold/spider2snow_eval.jsonl', 'r') as f:
        for line in f:
            data = json.loads(line)
            instance_id = data['instance_id']
            toks = int(data['toks'])
            toks_data[instance_id] = toks

    difficulty_counts = {'easy': 0, 'medium': 0, 'hard': 0}
    difficulty_correct = {'easy': 0, 'medium': 0, 'hard': 0}

    for item in final_results:
        instance_id = item['instance_id']
        score = item['score']
        if instance_id not in toks_data:
            print(f"warning ：'toks' of instance_id={instance_id} is not found")
            continue
        toks = toks_data[instance_id]
        if toks < 80:
            difficulty = 'easy'
        elif toks < 160:
            difficulty = 'medium'
        else:
            difficulty = 'hard'
        difficulty_counts[difficulty] += 1
        if score == 1:
            difficulty_correct[difficulty] += 1

    print({item['instance_id']: item['score'] for item in final_results})

    total_score = sum([item['score'] for item in final_results]) / len(final_results)
    print('No. of correct instances:', sum([item['score'] for item in final_results]))
    print('No. of instances:', len(final_results))
    print(f"score: {total_score}")

    for difficulty in ['easy', 'medium', 'hard']:
        count = difficulty_counts[difficulty]
        correct = difficulty_correct[difficulty]
        if count > 0:
            score = correct / count
            print(f"{difficulty.capitalize()} difficulty - correct count: {correct}, count: {count}, score: {score}")
        else:
            print(f"{difficulty.capitalize()} difficulty - no instances!")
    


def evaluate_spider2sql(args):
    mode = args.mode
    gold_sql_dir = os.path.join(args.gold_dir, "sql")
    gold_result_dir = os.path.join(args.gold_dir, "exec_result")
    pred_result_dir = args.result_dir
    eval_result_dir = os.path.join(pred_result_dir, "../eval_result")
    os.makedirs(eval_result_dir, exist_ok=True)
    
    eval_standard_dict = load_jsonl_to_dict("./gold/spider2snow_eval.jsonl")
    spider2sql_metadata = load_jsonl_to_dict(f"../{args.dev}.jsonl")

    if mode == "sql":
        pred_ids = list(set([file.split("@")[0] for file in os.listdir(args.result_dir) if file.endswith(".sql")]))
        # pred_ids = list(set([file.split(".")[0] for file in os.listdir(args.result_dir) if file.endswith(".sql")]))
    elif mode == 'exec_result':
        pred_ids = [file.split(".")[0] for file in os.listdir(args.result_dir) if file.endswith(".csv")]
    

    # import pdb; pdb.set_trace()

    gold_ids = list(eval_standard_dict.keys())
    previous_results = []
    candidate_ids = []
    for id in list(set(gold_ids).intersection(pred_ids)):
        if osp.exists(osp.join(eval_result_dir, f"{id}.json")):
            # 读取json
            with open(osp.join(eval_result_dir, f"{id}.json"), 'r') as f:
                previous_results.append(json.load(f))
        else:
            candidate_ids.append(id)
    results = []

    if not args.report:
        candidate_ids = sorted(candidate_ids)
        with Pool(processes=args.processes) as pool:
            with tqdm(total=len(candidate_ids)) as pbar:
                for result in pool.starmap(evaluate_instance, [
                    (id, mode, pred_result_dir, gold_result_dir, gold_sql_dir, eval_standard_dict, spider2sql_metadata, args.credential_path, eval_result_dir)
                    for id in candidate_ids
                ]):
                    results.append(result)
                    pbar.update(1)

    # Collect and print the final results
    final_results = results + previous_results

    if not final_results:
        print("No results to evaluate.")
        return

    get_score(final_results)    

    DEBUG_PREFIX = "SQL_DEBUG_" if args.is_sql_debug else ""
    with open(osp.join(args.result_dir, f"../{DEBUG_PREFIX}_pass@n_eval_result_with_error_infos.json"), 'w') as f:
        json.dump(final_results, f, indent=4)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Run evaluations for NLP models.")
    parser.add_argument("--dev", type=str, default="spider2-lite")
    parser.add_argument("--mode", type=str, choices=["sql", "exec_result"], default='sql', help="Mode of submission results")
    parser.add_argument("--result_dir", type=str, default="/home/jxchen/Spider2/spider2-lite/baselines/dailsql/postprocessed_data/1109pass@10_spider2-lite_CTX-200/RESULTS_MODEL-gpt-4o-2024-08-06-SQL-postprocessed", help="Result directory")
    parser.add_argument("--gold_dir", type=str, default="gold", help="Result directory")
    parser.add_argument("--is_sql_debug", action="store_true", default=False)
    parser.add_argument("--credential_path", type=str, default="./credentials/bigquery_credential.json")
    parser.add_argument("--processes", type=int, default=60)
    parser.add_argument("--report", action='store_true')
    args = parser.parse_args()
    
    if os.path.exists("temp"):
        shutil.rmtree("temp")
    os.makedirs("temp")
    
    # Set start method for multiprocessing
    set_start_method('spawn', force=True)

    s_time = time.time()
    evaluate_spider2sql(args)
    print(f"Time: {time.time() - s_time} s")
