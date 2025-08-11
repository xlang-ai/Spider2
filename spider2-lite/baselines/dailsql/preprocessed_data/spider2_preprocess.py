# import debugpy; debugpy.connect(("127.0.0.1", 5688))
import numpy as np
import json
import os
import os.path as osp
import spacy
import requests
import argparse
from datetime import date
import sys
import glob
import matplotlib.pyplot as plt
import re

proj_dir = osp.dirname(osp.dirname(osp.abspath(__file__)))
sys.path = [osp.join(proj_dir, '../')] + sys.path

from utils.utils import walk_metadata, get_special_function_summary\

def read_jsonl(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        return [json.loads(line) for line in file]

def plot_statistics(new_data):

    candidate_columns = [entry['No. of candidate columns'] for entry in new_data if entry['No. of candidate columns'] < 10000]  # TODO: hack < 10000
    gold_tables = [entry['No. of gold tables'] for entry in new_data]

    plt.figure(figsize=(10, 5))
    plt.hist(candidate_columns, bins=50, edgecolor='black')
    plt.title('Histogram of No. of Candidate Columns')
    plt.xlabel('Number of Candidate Columns')
    plt.ylabel('Frequency')
    plt.grid(True)
    # plt.savefig('No. of Candidate Columns.png')  # if needed, open it
    # plt.show()

    plt.figure(figsize=(10, 5))
    plt.hist(gold_tables, bins=range(min(gold_tables), max(gold_tables) + 1), edgecolor='black', align='left')
    plt.title('Histogram of No. of Gold Tables')
    plt.xlabel('Number of Gold Tables')
    plt.ylabel('Frequency')
    plt.grid(True)
    # plt.savefig('No. of Gold Tables.png')  # if needed, open it
    # plt.show()

def replace_table_names(sql_content, selected_tables_to_dbid):
    # logic checked at 0902
    table_names = list(selected_tables_to_dbid.keys())  
    table_names = sorted(table_names, key=len, reverse=True)
    total_substitutions = 0 
    for table_name in table_names:
        pattern = re.compile(r'\b' + re.escape(table_name) + r'\b(?!\.)')  
        new_table_name = f"{selected_tables_to_dbid[table_name]}.{table_name}"
        sql_content, num_subs = pattern.subn(new_table_name, sql_content)
        total_substitutions += num_subs
    return sql_content, total_substitutions


def process_table_json(args, proj_dir):
    os.makedirs(osp.join(proj_dir, f'preprocessed_data/{args.dev}'), exist_ok=True)
    db_stats_list = walk_metadata(args.dev)

    for item in db_stats_list:
        if 'table_names_original' in item:
            item['table_names'] = item['table_names_original']
            item['column_names'] = item['column_names_original']
 
    with open(osp.join(proj_dir, f"preprocessed_data/{args.dev}/tables_preprocessed.json"), "w", encoding="utf-8") as json_file:
        json.dump(db_stats_list, json_file, indent=4, ensure_ascii=False)

    # with open("tables_toy.json", "w", encoding="utf-8") as json_file:
    #     json.dump([db_stats_list[5]], json_file, indent=4, ensure_ascii=False)





def process_dev_json(args, proj_dir):
    def get_questionTok_and_gold_query_for_dev_json(data):
        nlp = spacy.load("en_core_web_sm")
        
        os.makedirs(osp.join(proj_dir, f'preprocessed_data/{args.dev}'), exist_ok=True)
        for item in data:
            # step1. 
            doc = nlp(item['question'])
            item['question_toks'] = [token.text for token in doc]

            # step2. 
            gold_sql_file = osp.join(proj_dir, f"../../evaluation_suite/gold/sql/{item['instance_id']}.sql")
            if not os.path.exists(gold_sql_file):
                item['query'] = ''
            else:
                with open(gold_sql_file, 'r', encoding='utf-8') as file:
                    gold_sql = file.read().strip()
                    item['query'] = gold_sql

            item['db_id'] = item['db']
            del item['db']
        return data
    
    with open(osp.join(proj_dir, f"preprocessed_data/{args.dev}/tables_preprocessed.json"), "r", encoding="utf-8") as json_file:
        table_json = json.load(json_file)

    data = read_jsonl(osp.join(proj_dir, f'../../{args.dev}.jsonl'))
    data = get_questionTok_and_gold_query_for_dev_json(data)
    data = get_special_function_summary(data)

    # option
    available_dbs = [table['db_id'] for table in table_json]
    dbid_to_ncols = {table['db_id']: table['db_stats']['No. of columns'] for table in table_json}
    dbid_to_table_names = {table['db_id']: table['table_names_original'] for table in table_json}

    new_data = []
    for entry in data:

        if not entry['db_id'] in available_dbs:
            print(f"warning: for '{entry['instance_id']}', its required db_id '{entry['db_id']}' is not exist in the metadata. please make sure the metadata is complete!")
            continue

        # 0922 statistics   
        db_id = entry['db_id']
        entry['No. of candidate columns'] = dbid_to_ncols[db_id]  # No. columns / SQL
        
        selected_tables_to_dbid = {}  
        table_names = dbid_to_table_names[db_id]
        for table_name in table_names:
            selected_tables_to_dbid[table_name] = db_id
        
        _, total_substitutions = replace_table_names(entry['query'], selected_tables_to_dbid)
        entry['No. of gold tables'] = total_substitutions  # No. tables / SQL. caution: in 1106, we don't release the gold SQL, so this statistics is not accurate.

        if total_substitutions == 0:
            if 'table_suffix' in entry['query'].lower() or '*`' in entry['query'].lower():
                entry['No. of gold tables'] = 20
            else:
                pass
                # print('when count the statistics, not captured any tables.', entry['instance_id'])

        new_data.append(entry)

    # print AVG No. of candidate columns and No. of gold tables
    candidate_columns = [entry['No. of candidate columns'] for entry in new_data]
    gold_tables = [entry['No. of gold tables'] for entry in new_data]
    print(f"AVG No. of candidate columns per instance: {np.mean(candidate_columns):.2f}")
    print(f"AVG No. of gold tables per instance: {np.mean(gold_tables):.2f}")

    plot_statistics(new_data)

    with open(osp.join(proj_dir, f'preprocessed_data/{args.dev}/{args.dev}_preprocessed.json'), 'w', encoding='utf-8') as file:
        json.dump(new_data, file, ensure_ascii=False, indent=4)



if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    parser.add_argument('--dev', default='spider2_dev', type=str, help='the name of dev file')
    args = parser.parse_args()

    process_table_json(args, proj_dir)
    process_dev_json(args, proj_dir)






