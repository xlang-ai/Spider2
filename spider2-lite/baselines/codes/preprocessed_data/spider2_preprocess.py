import glob
import json
import pickle
import os
import os.path as osp
import numpy as np
from datetime import date
import argparse
import sys
import copy

proj_dir = osp.dirname(osp.dirname(osp.abspath(__file__)))
sys.path = [osp.join(proj_dir, '../')] + sys.path

from utils.utils import walk_metadata, get_special_function_summary


def read_jsonl(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        return [json.loads(line) for line in file]

def preprocess_table_json(args):
    os.makedirs(osp.join(proj_dir, f'preprocessed_data/{args.dev}'), exist_ok=True)
    db_stats_list = walk_metadata(args.dev)


    output = []
    for table_data in db_stats_list:
        db_id = table_data.get("db_id", "")
        table_names = table_data.get("table_names_original", [])
        column_names = table_data.get("column_names_original", [])
        column_types = table_data.get("column_types", [])
        column_descriptions = table_data.get("column_descriptions", [])
        primary_keys = table_data.get("primary_keys", [])
        foreign_keys_indices = table_data.get("foreign_keys", [])
        
        schema_items = []
        
        for table_index, table_name in enumerate(table_names):
            col_names = [col[1] for col in column_names if col[0] == table_index]
            col_types = [column_types[i] for i, col in enumerate(column_names) if col[0] == table_index]
            try:
                col_comments = [column_descriptions[i] for i, col in enumerate(column_names) if col[0] == table_index]
            except:
                col_comments = []
                for i, col in enumerate(column_names):
                    if col[0] == table_index:
                        try:
                            desc = column_descriptions[i]
                        except IndexError:
                            print(f"warning: column_descriptions length is invalid!db:{db_id}, table:{table_name}, len(column_names): {len(column_names)}, len(column_descriptions): {len(column_descriptions)}")
                            desc = [None, None]
                        col_comments.append(desc)
            col_comments = [(item[1] or '') for item in col_comments]  
            
            pk_indicators = [1 if column_names.index(col) in primary_keys else 0 for col in column_names if col[0] == table_index]
            
            sample_rows = table_data.get("sample_rows", {}).get(table_name, [])  
            SAMPLE_ROWS_NUM = 1  
            sample_rows = sample_rows[:SAMPLE_ROWS_NUM]
            col_contents = [[] for _ in col_names]
            
            for row in sample_rows:
                for col_index, col_name in enumerate(col_names):
                    col_contents[col_index].append(str(row.get(col_name, "")))
            
            
            schema_item = {
                "table_name": table_name,
                "table_comment": "",
                "column_names": col_names,
                "column_types": col_types,
                "column_comments": col_comments,
                "column_contents": col_contents,
                "pk_indicators": pk_indicators
            }
            
            schema_items.append(schema_item)
        

        foreign_keys = []
        for fk in foreign_keys_indices:
            start_column_index, end_column_index = fk
            start_table_index = column_names[start_column_index][0]
            end_table_index = column_names[end_column_index][0]
            
            start_table_name = table_names[start_table_index]
            start_column_name = column_names[start_column_index][1]
            
            end_table_name = table_names[end_table_index]
            end_column_name = column_names[end_column_index][1]
            
            foreign_keys.append([start_table_name, start_column_name, end_table_name, end_column_name])
        

        output_item = {
            "db_id": db_id,
            "db_path": None,
            "schema": {
                "schema_items": schema_items,
                "foreign_keys": foreign_keys,
            }
        }
        
        output.append(output_item)


    output_file = osp.join(proj_dir, 'preprocessed_data/tables_preprocessed.json') 
    with open(output_file, 'w', encoding="utf-8") as f:
        json.dump(output, f, indent=2, ensure_ascii=False)



def preprocess_dev_json(args):

    data = read_jsonl(osp.join(proj_dir, f'../../{args.dev}.jsonl'))
    
    for item in data:

        gold_sql_file = osp.join(proj_dir, f"../../evaluation_suite/gold/sql/{item['instance_id']}.sql")
        if not os.path.exists(gold_sql_file):
            item['sql'] = ''
        else:
            with open(gold_sql_file, 'r', encoding='utf-8') as file:
                gold_sql = file.read().strip()
                item['sql'] = gold_sql

        item['text'] = item['question']
        item['db_id'] = item['db']
        del item['db']
        if '\n' in item['db_id']:
            item['db_id'] = item['db_id'].split('\n')

        item['table_labels'] = None
        item['column_labels'] = None
        item['matched_contents'] = {}
        item['source'] = 'spider2'

    data = get_special_function_summary(data)

    with open(osp.join(proj_dir, f'preprocessed_data/{args.dev}/{args.dev}_preprocessed.json'), 'w', encoding='utf-8') as file:
        json.dump(data, file, ensure_ascii=False, indent=4)


def combine_table_dev_json(args):

    with open(osp.join(proj_dir, 'preprocessed_data/tables_preprocessed.json'), 'r') as tables_file:
        tables_data = json.load(tables_file)

    with open(osp.join(proj_dir, f'preprocessed_data/{args.dev}/{args.dev}_preprocessed.json'), 'r') as dev_file:
        dev_data = json.load(dev_file)

    tables_dict = {table['db_id']: table for table in tables_data}

    keeped_data = []
    for i in range(len(dev_data)):
        new_item = dev_data[i]
        # print('------------instance_id:', new_item['instance_id'])
        if isinstance(new_item['db_id'], list):  # multi-db
            # print(f'for instance_id: {new_item["instance_id"]}, db_ids: {new_item["db_id"]}')
            if not all([db_id in tables_dict for db_id in new_item['db_id']]):
                continue

            for db_id in new_item['db_id']:
                # print('keys:', tables_dict[db_id].keys())
                # print('table num of db:', len(tables_dict[db_id]['schema']['schema_items']))
                
                if 'schema' not in new_item:
                    new_item['schema'] = copy.deepcopy(tables_dict[db_id]['schema'])  # caution: must use deepcopy
                    # print('initial:', len(new_item['schema']['schema_items']))
                else:
                    new_item['schema']['schema_items'] += tables_dict[db_id]['schema']['schema_items']
                    new_item['schema']['foreign_keys'] += tables_dict[db_id]['schema']['foreign_keys']
                    # print('added to:', len(new_item['schema']['schema_items']))
                    
        else:  # single-db
            # print(f'for instance_id: {new_item["instance_id"]}, db_ids: {new_item["db_id"]}')
            assert isinstance(new_item['db_id'], str)
            if new_item['db_id'] not in tables_dict:
                continue
            new_item['schema'] = tables_dict[new_item['db_id']]['schema']
        # print('id(new_item):', id(new_item))
        keeped_data.append(copy.deepcopy(new_item))


        
    with open(osp.join(proj_dir, f'preprocessed_data/{args.dev}/sft_{args.dev}_preprocessed.json'), 'w') as new_dev_file:
        json.dump(keeped_data, new_dev_file, indent=4)




if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    parser.add_argument('--dev', default='spider2_dev', type=str, help='the name of dev file')
    args = parser.parse_args()

    preprocess_table_json(args)
    preprocess_dev_json(args)
    combine_table_dev_json(args)
