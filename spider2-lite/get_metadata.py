import sqlite3
import json
import os
import random
from tqdm import tqdm
import pandas as pd
import random

def local_db_tables(db_name):
    conn = sqlite3.connect(db_name)
    cursor = conn.cursor()
    cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
    tables = cursor.fetchall()
    output_tables = []
    for table in tables:
        output_tables.append(table[0])
    return output_tables

def local_db_columns(db_name, table_name):
    conn = sqlite3.connect(db_name)

    cursor = conn.cursor()


    cursor.execute(f"PRAGMA table_info({table_name});")

    column_names = []
    column_types = []

    columns = cursor.fetchall()

    for col in columns:
        column_names.append(col[1])
        column_types.append(col[2])
    return column_names, column_types

def sample_three_columns(db_name, table_name):
    conn = sqlite3.connect(db_name)
    cursor = conn.cursor()

    # Retrieve all column names from the table
    cursor.execute(f"PRAGMA table_info({table_name});")
    columns = cursor.fetchall()
    column_names = [col[1] for col in columns]  # Extracting the column names

    # Randomly select three columns if there are at least three columns
    if len(column_names) >= 3:
        sampled_columns = random.sample(column_names, 3)
    else:
        raise ValueError("The table does not have enough columns to sample three.")

    # Construct SQL to select all data from the sampled columns
    sql_query = f"SELECT {', '.join(sampled_columns)} FROM {table_name}"
    cursor.execute(sql_query)
    data = cursor.fetchall()

    # Close the connection
    conn.close()

    # Format data into a two-dimensional list where each sublist contains the values from a row
    formatted_data = [list(row) for row in data]

    return formatted_data


def get_keys(db_name, table_name):
    conn = sqlite3.connect(db_name)

    cursor = conn.cursor()

    cursor.execute(f"PRAGMA table_info({table_name});")
    columns = cursor.fetchall()

    primary_keys = [col[1] for col in columns if col[5] != 0]

    cursor.execute(f"PRAGMA foreign_key_list({table_name});")
    output_info = cursor.fetchall()
    foreign_keys = []

    for fk in output_info:
        foreign_keys.append((table_name, fk[3], fk[2], fk[4]))

    return primary_keys, foreign_keys
    
def map_data_types(data_types):
    mapped_types = []

    for dtype in data_types:
        if "INT" in dtype.upper() or "NUM" in dtype.upper() or "FLOAT" in dtype.upper() or "DOUBLE" in dtype.upper() or "REAL" in dtype.upper():
            mapped_types.append("number")
        else:
            mapped_types.append("text")
    
    return mapped_types



def get_local_metadata(db_name, output_path):
    output_list = []
    
    for db in db_name:
        table_names = local_db_tables(db)
        
        column_names_original = []
        column_names_original.append([-1, "*"])
        column_types = ["text"]
        
        tab_col_dict = {}
        
        primary_keys = []
        foreign_keys_origin = []
        foreign_keys = []
        table_names_original = table_names
        columns_count = []
        
        for i, tab in enumerate(table_names):
            col_names, col_types = local_db_columns(db, tab)
            tab_col_dict[tab] = col_names
            primary_keys_i, foreign_keys_i = get_keys(db, tab)
            primary_keys_i_new = [col_names.index(pk)+len(column_names_original) for pk in primary_keys_i]
            primary_keys.extend(primary_keys_i_new)
            if foreign_keys_i != []:
                foreign_keys_origin.extend(foreign_keys_i)
            column_types.extend(col_types)
            columns_count.append(len(column_names_original))
            for col in col_names:
                column_names_original.append([i, col])
            
        
        db_id = db.split("/")[-1].split(".")[0]
        
        for item in foreign_keys_origin:
            l_table = item[0]
            try:
                l_table_index = table_names_original.index(item[0])
            except:
                import pdb; pdb.set_trace()
            l_column = item[1]
            r_table = item[2]
            r_table_index = table_names_original.index(item[2])
            r_column = item[3]
            
            l_key = tab_col_dict[l_table].index(l_column) + columns_count[l_table_index]
            r_key = tab_col_dict[r_table].index(r_column) + columns_count[r_table_index]
            
            foreign_keys.append([l_key, r_key])

            
        output_dict = {}
        output_dict["db_id"] = db_id
        output_dict["table_names_original"] = table_names_original
        output_dict["column_names_original"] = column_names_original
        output_dict["column_types"] = column_types
        output_dict["primary_keys"] = primary_keys
        output_dict["foreign_keys"] = foreign_keys
        
        output_list.append(output_dict)
            
    return output_list



from google.cloud import bigquery
import pickle
def read_pickle(file_path):
    with open(file_path, 'rb') as f:
        data = pickle.load(f)
    return data
def get_column_details(database_name, schema_name, table_name):
    os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "bigquery_credential.json"
    client = bigquery.Client()

    query = f"""
    SELECT
        column_name,
        data_type
    FROM
        `{database_name}.{schema_name}.INFORMATION_SCHEMA.COLUMNS`
    WHERE
        table_name = '{table_name}'
    """

    query_job = client.query(query)
    results = query_job.result().to_dataframe()

    column_names = results['column_name'].tolist()
    column_types = results['data_type'].tolist()

    return column_names, column_types


    

def map_data_types(data_types):
    mapped_types = []

    for dtype in data_types:
        if "INT" in dtype.upper() or "NUM" in dtype.upper() or "FLOAT" in dtype.upper() or "DOUBLE" in dtype.upper() or "REAL" in dtype.upper():
            mapped_types.append("number")
        else:
            mapped_types.append("text")
    
    return mapped_types

def get_bq_metadata(db_name):
    source_path = "../databases/bigquery_metadata/"
    
    output_list = []
    
    for db in db_name:

        column_names_original = []
        column_names_original.append([-1, "*"])
        column_types = ["text"]

        primary_keys = []
        foreign_keys = []
        
        
        pkl_files = [file.split('.')[0] for file in os.listdir(f"/Users/leifangyu/workspace/DataAgentBench/benchmark/source/schema/bigquery/{db.split('.')[0]}") if file.endswith('.pkl')]
        if db.split(".")[1] in pkl_files:
            schema_data = read_pickle(f"/Users/leifangyu/workspace/DataAgentBench/benchmark/source/schema/bigquery/{db.split('.')[0]}/{db.split('.')[1]}.schema.pkl")
            output_dict = {}
            table_names_original =[item['table_name'] for item in schema_data]
            
            for i, table in enumerate(schema_data):
                column_names = [col['column_name'] for col in table['columns_info']]
                data_types = [col['data_type'] for col in table['columns_info']]
                column_types_i = data_types
                for col in column_names:
                    column_names_original.append([i, col])
                column_types.extend(column_types_i)
        else:
            source_path += db.split(".")[0] + "/" + db.split(".")[1] + "/"
            file_paths = [os.path.join(source_path, file) for file in os.listdir(source_path) if os.path.isfile(os.path.join(source_path, file))]
            table_names_original = [name.replace('.md','') for name in os.listdir(source_path)]
            for i, file in enumerate(file_paths):
                column_names, data_types = get_column_details(db.split(".")[0], db.split(".")[1], file.split("/")[-1].replace('.md','').split(".")[2])
                column_types_i = data_types
                for col in column_names:
                    column_names_original.append([i, col])
                column_types.extend(column_types_i)
            
        output_dict = {}
        output_dict["db_id"] = db
        output_dict["table_names_original"] = table_names_original
        output_dict["column_names_original"] = column_names_original
        output_dict["column_types"] = column_types
        output_dict["primary_keys"] = primary_keys
        output_dict["foreign_keys"] = foreign_keys
        

        
        output_list.append(output_dict)

    return output_list


def load_json(filename):
    with open(filename, 'r') as file:
        data = json.load(file)
    return data


def get_bigquery_metadata(project_name, dataset_name):
    os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "bigquery_credential.json"
    client = bigquery.Client()
    
    dataset_metadata = None
    output = {}
    
    # 1. get the tables
    query = f"""
    SELECT
        table_name, ddl
    FROM
     `{project_name}.{dataset_name}.INFORMATION_SCHEMA.TABLES`
    WHERE table_type != 'VIEW'
    """
    query_job = client.query(query)
    dataset_metadata = query_job.result().to_dataframe()

    tables_metadata = []

    # 2. Get the columns 3. get the nested columns
    for table in tqdm(dataset_metadata['table_name'].tolist()):
        table_metadata = {}
        
        query = f"""
            SELECT column_name, data_type
            FROM `{project_name}.{dataset_name}.INFORMATION_SCHEMA.COLUMNS`
            WHERE table_name = '{table}';
        """
        query_job = client.query(query)
        output = query_job.result().to_dataframe()
        column_names, data_types = output['column_name'].tolist(), output['data_type'].tolist()
        
        query = f"""
            SELECT field_path, data_type, description
            FROM `{project_name}.{dataset_name}.INFORMATION_SCHEMA.COLUMN_FIELD_PATHS`
            WHERE table_name = '{table}';
        """
        query_job = client.query(query)
        output = query_job.result().to_dataframe()
        nested_column_names, nested_column_types, description = output['field_path'].tolist(), output['data_type'].tolist(), output['description'].tolist()
    
        
        table_metadata['table_name'] = table
        table_metadata['table_fullname'] = f"{project_name}.{dataset_name}.{table}"
        table_metadata['column_names'] = column_names
        table_metadata['column_types'] = data_types
        table_metadata['nested_column_names'] = nested_column_names
        table_metadata['nested_column_types'] = nested_column_types
        table_metadata['description'] = description
        
        query = f"""
                SELECT
                *
                FROM
                `{project_name}.{dataset_name}.{table}`
                TABLESAMPLE SYSTEM (0.0001 PERCENT)
                LIMIT 5
                ;
        """  
        query_job = client.query(query)
        output = query_job.result().to_dataframe()
        sample_rows = output.to_dict(orient='records')
        table_metadata['sample_rows'] = sample_rows
        tables_metadata.append(table_metadata)
    
    return dataset_metadata, tables_metadata





def load_json(filename):
    with open(filename, 'r') as file:
        data = json.load(file)
    return data


import traceback
import snowflake.connector
def get_snowflake_schema(database_name, schema_name):
    print(f"{database_name}.{schema_name}")
    snowflake_credential = load_json('snowflake_credential.json')
    table_number = 0
    conn = snowflake.connector.connect(
        **snowflake_credential,
        database=database_name
    )
    
    cursor = conn.cursor()
    output_str = ""
    
    dataset_metadata = None
    
    query = f"""
    SELECT table_name, comment
    FROM "{database_name}".INFORMATION_SCHEMA.TABLES
    WHERE table_schema = '{schema_name}'
    """

    cursor.execute(query)
    tables_information = cursor.fetchall()
    dataset_metadata = pd.DataFrame(tables_information, columns=['table_name', 'description'])
    
    tables_metadata = []
    
    for table_name in tqdm(dataset_metadata['table_name'].tolist()):
        
        table_metadata = {}
        try:
            query = f"""
            SELECT
                *
            FROM
                \"{schema_name}\".\"{table_name}\"
            TABLESAMPLE BERNOULLI (50)
            LIMIT 5;
            """
            cursor.execute(query)
            output = cursor.fetchall()
            columns = [desc[0] for desc in cursor.description]
            df = pd.DataFrame(output, columns=columns)
            sample_rows = df.to_dict(orient='records')
            table_metadata['sample_rows'] = sample_rows   
        except Exception as e:
            error_message = traceback.format_exc()
            if "does not exist or not authorized" in error_message:
                print(f"{schema_name}.{table_name}, error_message")
                continue
            else:
                print(error_message)
                pass
        
        query = f"""
        SELECT
            column_name,
            data_type,
            comment
        FROM
            "{database_name}".INFORMATION_SCHEMA.COLUMNS
        WHERE
            table_schema = '{schema_name}' AND
            table_name = '{table_name}'
        """
        cursor.execute(query)
        df = pd.DataFrame(cursor.fetchall(), columns=['column_names', 'column_types', "description"])
        
        table_metadata['table_name'] = f"{schema_name}.{table_name}"
        table_metadata['table_fullname'] = f"{database_name}.{schema_name}.{table_name}"
        table_metadata['column_names'] = df["column_names"].tolist()
        table_metadata['column_types'] = df["column_types"].tolist()
        table_metadata['description'] = df["description"].tolist()
        tables_metadata.append(table_metadata)
        
        table_number += 1
        
    os.makedirs('snowflake', exist_ok=True)
    cursor.close()
    conn.close()
    print("Number of tables: ", table_number)
    return dataset_metadata, tables_metadata



if __name__ == "__main__":

    
    with open("spider2-lite.json", 'r', encoding='utf-8') as file:
        spider2_data = json.load(file)
        
    local_db_name, bq_db_name, sf_db_name = set(), set(), set()
    local_db_path = []
    for data in spider2_data:
        if data['instance_id'].startswith('local') and not data['instance_id'].endswith('bq'):
            local_db_name.add(data['db'])
        elif data['instance_id'].startswith('bq') or data['instance_id'].startswith('ga') or (data['instance_id'].startswith('local') and data['instance_id'].endswith('bq')):
            if '\n' in data['db']:
                bq_db_name.update(data['db'].split('\n'))
            else:
                bq_db_name.add(data['db'])
        elif data['instance'].startswith('sf'):
            sf_db_name.add(data['db'])
                

    db_ids = []
    root_dir = './resource/databases/bigquery/'
    for folder_name_a in os.listdir(root_dir):
        folder_path_a = os.path.join(root_dir, folder_name_a)
        if os.path.isdir(folder_path_a):  # Check if it's a directory
            has_json = any(file.endswith('.json') for file in os.listdir(folder_path_a))
            if has_json:
                db_ids.append(f"{folder_name_a}")

    bq_db_name = list(bq_db_name - set(db_ids))

    for db_name in tqdm(bq_db_name):
        try:
            project_name, dataset_name = db_name.split('.')[0], db_name.split('.')[1]
        except:
            import pdb; pdb.set_trace()
        print(f"{project_name}.{dataset_name}")
        dataset_metadata, tables_metadata = get_bigquery_metadata(project_name, dataset_name)


        directory = os.path.join(root_dir, f"{project_name}.{dataset_name}")
        if not os.path.exists(directory):
            os.makedirs(directory)
        df = pd.DataFrame(dataset_metadata)
        ddl_csv_path = os.path.join(directory, 'DDL.csv')
        df.to_csv(ddl_csv_path, index=False)

        for table_meta in tables_metadata:
            table_name = table_meta['table_name']
            file_path = os.path.join(directory, f"{table_name}.json")
            json_data = json.dumps(table_meta, indent=4, default=str)
            with open(file_path, 'w') as json_file: 
                json_file.write(json_data)


    sf_db_ids = []
    root_dir = './resource/databases/snowflake/'
    for folder_name_a in os.listdir(root_dir):
        folder_path_a = os.path.join(root_dir, folder_name_a)
        if os.path.isdir(folder_path_a):  # Check if it's a directory
            has_json = any(file.endswith('.json') for file in os.listdir(folder_path_a))
            if has_json:
                sf_db_ids.append(f"{folder_name_a}")
    
    sf_db_name = list(sf_db_name - set(sf_db_ids))
    
    sf_db_name = [
        "AMAZON_VENDOR_ANALYTICS__SAMPLE_DATASET.PUBLIC",
        "BRAZE_USER_EVENT_DEMO_DATASET.PUBLIC",
        "CENSUS_GALAXY__AIML_MODEL_DATA_ENRICHMENT_SAMPLE.public",
        "CENSUS_GALAXY__ZIP_CODE_TO_BLOCK_GROUP_SAMPLE.public",
        "FINANCE__ECONOMICS.CYBERSYN",
        "GLOBAL_GOVERNMENT.CYBERSYN",
        "GLOBAL_WEATHER__CLIMATE_DATA_FOR_BI.STANDARD_TILE",
        "NETHERLANDS_OPEN_MAP_DATA.NETHERLANDS",
        "US_ADDRESSES__POI.CYBERSYN",
        "US_REAL_ESTATE.CYBERSYN",
        "WEATHER__ENVIRONMENT.CYBERSYN",
        "YES_ENERGY__SAMPLE_DATA.yes_energy_sample"
    ]

    root_dir = './resource/databases/snowflake/'
    for item in sf_db_name:
        database_name, schema_name = item.split(".")
        dataset_metadata, tables_metadata = get_snowflake_schema(database_name, schema_name)
        directory = os.path.join(root_dir, f"{database_name}.{schema_name}")
        if not os.path.exists(directory):
            os.makedirs(directory)
        df = pd.DataFrame(dataset_metadata)
        ddl_csv_path = os.path.join(directory, 'DDL.csv')
        df.to_csv(ddl_csv_path, index=False)

        for table_meta in tables_metadata:
            table_name = table_meta['table_name']
            file_path = os.path.join(directory, f"{table_name}.json")
            json_data = json.dumps(table_meta, indent=4, default=str)
            with open(file_path, 'w') as json_file: 
                json_file.write(json_data)