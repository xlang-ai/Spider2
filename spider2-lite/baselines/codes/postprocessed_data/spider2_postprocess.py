import os
import json
import re
import os.path as osp
import argparse
import sys

proj_dir = osp.dirname(osp.dirname(osp.abspath(__file__)))
sys.path = [osp.join(proj_dir, '../')] + sys.path
from utils.post_utils import postprocess_sql_by_dialect

def load_json(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        return json.load(file)


def main(root_path, dev_json, table_json):

    json1 = load_json(dev_json)
    json2 = load_json(table_json)

    dbid_to_tables = {
        item["db_id"]: [schema_item["table_name"] for schema_item in item["schema"]["schema_items"]]
        for item in json2
    }
    instance_id_to_db_id = {item["instance_id"]: item["db_id"] for item in json1}

    new_root_path = root_path + "-postprocessed"
    os.makedirs(new_root_path, exist_ok=True)

    for root, _, files in os.walk(root_path):
        for file_name in files:
            if file_name.endswith('.sql'):
                instance_id = file_name.split('.')[0].split('@')[0]

                assert instance_id in instance_id_to_db_id, "check the dev.json"

                db_id = instance_id_to_db_id[instance_id]
                if isinstance(db_id, str): db_id = [db_id]
                selected_tables_to_dbid = {}        
                for k, v in dbid_to_tables.items():
                    if k in db_id:
                        for vv in v:
                            if vv in selected_tables_to_dbid.keys():  # should assure no tables with duplicated names. 
                                print(f"WARNING: Key '{vv}' already exists in 'selected_tables_to_dbid'.")
                            else:
                                selected_tables_to_dbid[vv] = k  

                sql_file_path = os.path.join(root, file_name)
                with open(sql_file_path, 'r', encoding='utf-8') as sql_file:
                    sql_content = sql_file.read()

                new_sql_content = postprocess_sql_by_dialect(sql_content, selected_tables_to_dbid, file_name)  # core
                
                new_sql_file_path = os.path.join(new_root_path, file_name)
                with open(new_sql_file_path, 'w', encoding='utf-8') as sql_file:
                    sql_file.write(new_sql_content)


if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument('--dev', default='spider2_dev', type=str, help='the name of dev file')
    parser.add_argument("--comment", type=str, default='')
    args = parser.parse_args()

    root_path = osp.join(proj_dir, f'postprocessed_data/{args.comment}-{args.dev}/{args.dev}-pred-sqls')
    dev_json = osp.join(proj_dir, f'preprocessed_data/{args.dev}/{args.dev}_preprocessed.json')
    table_json = osp.join(proj_dir, 'preprocessed_data/tables_preprocessed.json')
    
    main(root_path, dev_json, table_json)


