import re
import json

def load_json(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        return json.load(file)

def replace_table_names(sql_content, selected_tables_to_dbid):
    # logic checked at 0923
    table_names = list(selected_tables_to_dbid.keys())  
    table_names = sorted(table_names, key=len, reverse=True)
    for table_name in table_names:
        pattern = re.compile(r'(?<!\.)\b' + re.escape(table_name) + r'\b(?!\.)')  
        new_table_name = f"{selected_tables_to_dbid[table_name]}.{table_name}"
        sql_content = pattern.sub(new_table_name, sql_content)
    return sql_content


def postprocess_sql_by_dialect(sql_content, selected_tables_to_dbid, file_name):
    if file_name.startswith('local'):
        new_sql_content = sql_content
    elif file_name.startswith('bq') or file_name.startswith('ga'):  # bq
        new_sql_content = replace_table_names(sql_content, selected_tables_to_dbid)
    elif file_name.startswith('sf'):  # snowflake
        new_sql_content = replace_table_names(sql_content, selected_tables_to_dbid)  # TODO NEXT check
    else:
        raise ValueError(f"Unknown database type: {file_name}")
    return new_sql_content


def spider2_postprocess_single_sql(
    sql_content, 
    instance_id,
    dev_json='/data1/yyx/text2sql/Spider2/spider2-lite/baselines/dailsql/preprocessed_data/toy/toy_preprocessed.json',  # TODO
    table_json='/data1/yyx/text2sql/Spider2/spider2-lite/baselines/dailsql/preprocessed_data/toy/tables_preprocessed.json',  # TODO
):
    # Load the necessary JSON data
    json1 = load_json(dev_json)
    json2 = load_json(table_json)

    # Create mappings from the JSON data
    dbid_to_tables = {item["db_id"]: item["table_names_original"] for item in json2}
    instance_id_to_db_id = {item["instance_id"]: item["db_id"] for item in json1}

    # Check if the instance ID is in the JSON mapping
    assert instance_id in instance_id_to_db_id, "Check the dev.json for the provided instance_id."

    # Get the database ID for the instance
    db_id = instance_id_to_db_id[instance_id]
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