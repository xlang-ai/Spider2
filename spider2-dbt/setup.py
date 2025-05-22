import os
import json
import shutil
import zipfile
import argparse

jsonl_path = 'examples/spider2-dbt.jsonl'



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

if __name__ == '__main__':
    setup_dbt()


