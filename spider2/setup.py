import os
import json
import shutil
import zipfile
import argparse

jsonl_path = 'examples/spider2.jsonl'



def setup_bigquery():

    credential_path = 'bigquery_credential.json'
    instance_ids = []
    with open(jsonl_path, 'r') as file:
        for line in file:
            record = json.loads(line)
            if record.get('type') == 'Bigquery':
                instance_id = record.get('instance_id')
                if instance_id:
                    instance_ids.append(instance_id)
    for instance_id in instance_ids:
        folder_path = f'examples/{instance_id}'
        target_credential_path = os.path.join(folder_path, 'bigquery_credential.json')
        # Check if the folder exists
        if not os.path.exists(folder_path):
            os.makedirs(folder_path)
        # Replace the credential file if it exists, or copy a new one if it doesn't
        if os.path.exists(target_credential_path):
            os.remove(target_credential_path)
        shutil.copy(credential_path, target_credential_path)
    print("Finished BigQuery setup...")


def setup_snowflake():
    credential_path = 'snowflake_credential.json'
    instance_ids = []
    with open(jsonl_path, 'r') as file:
        for line in file:
            record = json.loads(line)
            if record.get('type') == 'Snowflake':
                instance_id = record.get('instance_id')
                if instance_id:
                    instance_ids.append(instance_id)
    for instance_id in instance_ids:
        folder_path = f'examples/{instance_id}'
        target_credential_path = os.path.join(folder_path, 'snowflake_credential.json')

        if os.path.exists(target_credential_path):
            os.remove(target_credential_path)

        shutil.copy(credential_path, target_credential_path)
        print(f"Copied Snowflake credential for instance {instance_id}.")
    
    print("Finished Snowflake setup...")

def setup_local(database_type):


    zip_file_path = './local_sqlite.zip'
    extract_to_path = './resource/databases/local'

    os.makedirs(extract_to_path, exist_ok=True)

    with zipfile.ZipFile(zip_file_path, 'r') as zip_ref:
        zip_ref.extractall(extract_to_path)

    
    with open('./resource/databases/local/local-map.jsonl', 'r') as infile:
        for line in infile:
            local_map = json.loads(line)
    instance_ids = []
    with open(jsonl_path, 'r') as file:
        for line in file:
            record = json.loads(line)
            if record.get('type') == 'Local':
                instance_id = record.get('instance_id')
                if instance_id:
                    instance_ids.append(instance_id)    
    for instance_id in instance_ids:
        try:
            db_name = local_map[instance_id]
        except:
            print(f"Coundn't setup example {instance_id}.")
            continue
        folder_path = f'examples/{instance_id}'
        if database_type == 'local':
            db_path = os.path.join(f'./resource/databases/local', f"{db_name}.sqlite")
            target_db_path = os.path.join(folder_path, f"{db_name}.sqlite")
        else:
            db_path = os.path.join(f'./resource/databases/{database_type}', f"{db_name}.{database_type}") 
            target_db_path = os.path.join(folder_path, f"{db_name}.{database_type}")
        if not os.path.exists(folder_path):
            os.makedirs(folder_path)
        if os.path.exists(target_db_path):
            os.remove(target_db_path)
        shutil.copy(db_path, target_db_path)
        print(f"successfully copied {db_name}.{database_type} to {folder_path}")
    
    print("Finished local setup...")
    

def setup_dbt():
    ###############################################
    prefixes = ('bq', 'ga', 'local', 'sf')

    def delete_duckdb_files(folder_path):
        for root, dirs, files in os.walk(folder_path):
            for file in files:
                if file.endswith('.duckdb'):
                    file_path = os.path.join(root, file)
                    os.remove(file_path)
                    print(f'Deleted {file_path}')

    examples_path = './examples'
    for folder in os.listdir(examples_path):
        folder_path = os.path.join(examples_path, folder)
        if os.path.isdir(folder_path) and not folder.startswith(prefixes):
            delete_duckdb_files(folder_path)

    gold_path = './evaluation_suite/gold'
    for folder in os.listdir(gold_path):
        folder_path = os.path.join(gold_path, folder)
        if os.path.isdir(folder_path) and not folder.startswith(prefixes):
            delete_duckdb_files(folder_path)
    ################################################    
    
    
    
    def process_zip_file(zip_path, target_base_path, extraction_dir):
        with zipfile.ZipFile(zip_path, 'r') as zip_ref:
            zip_ref.extractall(extraction_dir)
        
        for folder in os.listdir(extraction_dir):
            folder_path = os.path.join(extraction_dir, folder)
            
            if folder == "__MACOSX":
                continue
            
            if os.path.isdir(folder_path):
                folder_id = folder
                
                for root, dirs, files in os.walk(folder_path):
                    for file in files:
                        if file.endswith('.duckdb'):
                            target_folder = os.path.join(target_base_path, folder_id)
                            if not os.path.exists(target_folder):
                                os.makedirs(target_folder)
                            
                            source_file = os.path.join(root, file)
                            destination_file = os.path.join(target_folder, file)
                            
                            shutil.move(source_file, destination_file)
                            print(f'Moved {source_file} to {destination_file}')
        
        shutil.rmtree(extraction_dir)
        print(f'Deleted extraction directory: {extraction_dir}')

    temp_spider2_dir = './temp_spider2'
    temp_dbt_gold_dir = './temp_dbt_gold'

    spider2_zip_path = 'DBT_start_db.zip'
    examples_target_path = './examples'
    process_zip_file(spider2_zip_path, examples_target_path, temp_spider2_dir)

    dbt_gold_zip_path = 'dbt_gold.zip'
    gold_target_path = './evaluation_suite/gold'
    process_zip_file(dbt_gold_zip_path, gold_target_path, temp_dbt_gold_dir)

    print("Finished dbt setup...")
    
error_dbs = []
def setup_add_schema(args):
    instance_ids = []
    with open(jsonl_path, 'r') as file:
        for line in file:
            record = json.loads(line)
            instance_id = record.get('instance_id')
            instance_ids.append(instance_id)
    with open('./resource/databases/local/local-map.jsonl', 'r') as infile:
        for line in infile:
            local_map = json.loads(line)
            
    schema_root = '../spider2-lite/resource/databases/'
            
    for instance_id in instance_ids:
        if not instance_id.startswith(('bq', 'ga', 'sf')): continue
        
        example_folder = f'examples/{instance_id}'
        assert os.path.exists(example_folder)
        dest_folder = os.path.join(example_folder, 'DB_schema')
        if os.path.exists(dest_folder):
            shutil.rmtree(dest_folder)
        else:
            os.makedirs(dest_folder)

        databases = local_map[instance_id].split('\n')

        if instance_id.startswith('bq') or instance_id.startswith('ga'):
            for db in databases:
                src_folder = os.path.join(schema_root, 'bigquery', db)
                try:
                    shutil.copytree(src_folder, os.path.join(dest_folder, os.path.basename(src_folder)))
                except:
                    error_dbs.append(db)
                    continue
                print(f"successfully copied {db} to {dest_folder}")
        elif instance_id.startswith('sf'):
            for db in databases:
                src_folder = os.path.join(schema_root, 'snowflake', db)
                shutil.copytree(src_folder, os.path.join(dest_folder, os.path.basename(src_folder)))
                print(f"successfully copied {db} to {dest_folder}")
    print(f"ERROR_DB\n{list(set(error_dbs))}")

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Setup for Spider 2.0")
    parser.add_argument("--bigquery", action="store_true", help="Setup BigQuery")
    parser.add_argument("--snowflake", action="store_true", help="Setup Snowflake")
    parser.add_argument("--local", action="store_true", help="Setup local environment")
    parser.add_argument("--duckdb", action="store_true", help="Setup local environment")
    parser.add_argument("--dbt", action="store_true", help="Setup dbt")
    parser.add_argument("--add_schema", action="store_true", help="Add schema")

    args = parser.parse_args()

    if args.bigquery:
        setup_bigquery()
    if args.snowflake:
        setup_snowflake()
    if args.local:
        setup_local("local")
    elif args.duckdb:
        setup_local("duckdb")
    if args.dbt:
        setup_dbt()

    if not (args.bigquery or args.snowflake or args.local or args.dbt):
        setup_bigquery()
        setup_snowflake()
        setup_local("local")
        setup_dbt()

    if args.add_schema:
        setup_add_schema(args)

