import sqlite3
import json
import argparse
from func_timeout import func_set_timeout, FunctionTimedOut

def parse_option():
    parser = argparse.ArgumentParser()
    
    parser.add_argument('--pred', type = str, default = "pred_sqls.txt")
    parser.add_argument('--gold', type = str, default = "./data/test.json")
    parser.add_argument('--db', type = str, default = "./data/database/everbright_bank/everbright_bank.sqlite")
    
    opt = parser.parse_args()

    return opt

@func_set_timeout(60)
def execute_sql(cursor, sql):
    cursor.execute(sql)
    sql_res = cursor.fetchall()

    return sql_res

def compare_sql(predicted_sql, ground_truth, db_path):
    conn = sqlite3.connect(db_path, check_same_thread = False)
    # Connect to the database
    cursor = conn.cursor()

    ground_truth_res = execute_sql(cursor, ground_truth)
    try:
        predicted_res = execute_sql(cursor, predicted_sql)
    except Exception as e:
        print("raises an error: {}.".format(str(e)))
        return 0, None, ground_truth_res
    except FunctionTimedOut as fto:
        print("raises an error: time out.")
        return 0, None, ground_truth_res

    res = 0
    if set(predicted_res) == set(ground_truth_res):
        res = 1
    return res, predicted_res, ground_truth_res

if __name__ == "__main__":
    opt = parse_option()
    pred_sqls = [line.strip() for line in open(opt.pred).readlines()]
    questions = [data["question"] for data in json.load(open(opt.gold))]
    ground_truth_sqls = [data["sql"] for data in json.load(open(opt.gold))]

    results = []
    for question, pred, ground_truth in zip(questions, pred_sqls, ground_truth_sqls):
        # print(ground_truth)
        res, predicted_res, ground_truth_res = compare_sql(pred, ground_truth, opt.db)
        
        if res == 0:
            print("question:", question)
            print("pred sql:", pred)
            print("gt sql:", ground_truth)
            if predicted_res is not None:
                print("results of pred sql:", predicted_res[:20])
            else:
                print("results of pred sql: None")
            print("results of gt sql:", ground_truth_res[:20])
            print("-"*30)
        
        results.append(res)
    
    print("EX score:", sum(results)/len(results))