import os
import re
import json

def load_json(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        return json.load(file)

def replace_table_names(sql_content, selected_tables_to_projDataset):
    # logic checked at 0923
    table_names = list(selected_tables_to_projDataset.keys())  
    table_names = sorted(table_names, key=len, reverse=True)
    for table_name in table_names:
        pattern = re.compile(r'(?<!\.)\b' + re.escape(table_name) + r'\b(?!\.)')  
        new_table_name = f"{selected_tables_to_projDataset[table_name]}.{table_name}"
        sql_content = pattern.sub(new_table_name, sql_content)
    return sql_content


def postprocess_sql_by_dialect(sql_content, selected_tables_to_projDataset, file_name):
    if file_name.startswith('local'):
        new_sql_content = sql_content
    elif file_name.startswith('bq') or file_name.startswith('ga'):  # bq
        new_sql_content = replace_table_names(sql_content, selected_tables_to_projDataset)
    elif file_name.startswith('sf'):  # snowflake
        new_sql_content = replace_table_names(sql_content, selected_tables_to_projDataset)  # TODO NEXT check
    else:
        raise ValueError(f"Unknown database type: {file_name}")
    return new_sql_content


def spider2_postprocess_single_sql(
    sql_content, 
    instance_id,
    dev_json_path='/data1/yyx/text2sql/Spider2/spider2-lite/baselines/dailsql/preprocessed_data/toy/toy_preprocessed.json',  # TODO
    table_json_path='/data1/yyx/text2sql/Spider2/spider2-lite/baselines/dailsql/preprocessed_data/toy/tables_preprocessed.json',  # TODO
):
    '''
    status: deprecated. we don't use self-consistency in dai-sql
    '''

    # Load the necessary JSON data
    dev_json = load_json(dev_json_path)
    table_json = load_json(table_json)

    # Create mappings from the JSON data
    dbid_to_tables = {entry["db_id"]: entry["table_names_original"] for entry in table_json}
    instanceid_to_dbid = {entry["instance_id"]: entry["db_id"] for entry in dev_json}

    # Check if the instance ID is in the JSON mapping
    assert instance_id in instanceid_to_dbid, "Check the dev.json for the provided instance_id."

    # Get the database ID for the instance
    db_id = instanceid_to_dbid[instance_id]
    if isinstance(db_id, str): 
        db_id = [db_id]

    # Prepare a dictionary of selected tables mapped to their db_id
    selected_tables_to_dbid = {}
    for k, v in dbid_to_tables.items():
        if k in db_id:
            for vv in v:
                if vv in selected_tables_to_dbid.keys():
                    print(f"WARNING: Key '{vv}' already exists in 'selected_tables_to_dbid'.")
                else:
                    selected_tables_to_dbid[vv] = k

    new_sql_content = replace_table_names(sql_content, selected_tables_to_dbid)

    # Return the modified SQL content
    return new_sql_content


def main_postprocess(root_path, dev_json_path, table_json_path, method):

    dev_json = load_json(dev_json_path)
    table_json = load_json(table_json_path)

    assert method in ['DAIL-SQL', 'DIN-SQL', 'CHESS', 'CODES']    
    if method == 'CODES':
        dbid_to_tables = {
           entry["db_id"]: [schema_item["table_name"] for schema_item in entry["schema"]["schema_items"]]
            for entry in table_json
        }
    elif method in ('DAIL-SQL', 'DIN-SQL'):
        dbid_to_tables = {entry["db_id"]: entry["table_names_original"] for entry in table_json}
    else:
        raise NotImplementedError
    dbid_to_projDataset = {entry['db_id']: entry['table_to_projDataset'] for entry in table_json}

    instanceid_to_dbid = {entry["instance_id"]: entry["db_id"] for entry in dev_json}


    new_root_path = root_path + "-postprocessed"
    os.makedirs(new_root_path, exist_ok=True)

    for root, _, files in os.walk(root_path):
        for file_name in files:  # traverse the inferenced sql
            if not file_name.endswith('.sql'): continue

            # step1. get the instance_id and db_id
            instance_id = file_name.split('.')[0].split('@')[0]  # for pass-mode
            if not instance_id in instanceid_to_dbid:
                print(f">>>warning: not existed instance_id:{instance_id}. check the dev.json.")
                continue
            db_id = instanceid_to_dbid[instance_id]

            # step2. prepare the selected_tables_to_projDataset
            selected_tables_to_projDataset = {}        
            for table in dbid_to_tables[db_id]:  # TODO NEXT should change to project.dataset
                if table in selected_tables_to_projDataset.keys():  # should assure no tables with duplicated names. 
                    print(f"WARNING: Key '{table}' already exists, which means there is a duplicated table name.")
                else:
                    selected_tables_to_projDataset[table] = dbid_to_projDataset[db_id][table]

            sql_file_path = os.path.join(root, file_name)
            with open(sql_file_path, 'r', encoding='utf-8') as sql_file:
                sql_content = sql_file.read()
            new_sql_content = postprocess_sql_by_dialect(sql_content, selected_tables_to_projDataset, file_name)  # core

            new_sql_file_path = os.path.join(new_root_path, file_name)
            with open(new_sql_file_path, 'w', encoding='utf-8') as sql_file:
                sql_file.write(new_sql_content)