import os
import json
import shutil
import zipfile
import argparse
from tqdm import tqdm

JSONL_PATH = '../../spider2-lite/spider2-lite.jsonl'
DATABASE_PATH_BQ = '../../spider2-lite/resource/databases/bigquery/'
DATABASE_PATH_SF = '../../spider2-lite/resource/databases/snowflake/'
DATABASE_PATH_SQLITE = '../../spider2-lite/resource/databases/spider2-localdb/'
DOCUMENT_PATH = '../../spider2-lite/resource/documents'


def clear_folder(folder_path):
    if os.path.exists(folder_path):
        shutil.rmtree(folder_path)
        os.makedirs(folder_path)
    else:
        print(f"The folder {folder_path} does not exist.")



def setup_snowflake():
    credential_path = 'snowflake_credential.json'
    with open(JSONL_PATH, "r") as f:
        examples = [json.loads(line) for line in f]
    for example in examples:
        instance_id = example['instance_id']
        folder_path = f'examples/{instance_id}'
        target_credential_path = os.path.join(folder_path, 'snowflake_credential.json')

        if os.path.exists(target_credential_path):
            os.remove(target_credential_path)

        shutil.copy(credential_path, target_credential_path)
        print(f"Copied Snowflake credential for instance {instance_id}.")
    
    print("Finished Snowflake setup...")


def setup_bigquery():
    credential_path = 'bigquery_credential.json'
    with open(JSONL_PATH, "r") as f:
        examples = [json.loads(line) for line in f]
    for example in examples:
        instance_id = example['instance_id']
        folder_path = f'examples/{instance_id}'
        target_credential_path = os.path.join(folder_path, 'bigquery_credential.json')

        if os.path.exists(target_credential_path):
            os.remove(target_credential_path)

        shutil.copy(credential_path, target_credential_path)
        print(f"Copied Bigquery credential for instance {instance_id}.")
    
    print("Finished Bigquery setup...")


    
error_dbs = []
def setup_add_schema(args):

    with open(JSONL_PATH, "r") as f:
        examples = [json.loads(line) for line in f]            
            
    for example in examples:
        instance_id = example['instance_id']
        db_id = example['db_id']
        example_folder = f'examples/{instance_id}'
        assert os.path.exists(example_folder)
        dest_folder = os.path.join(example_folder, db_id)  # Use db_id as the folder name
        if os.path.exists(dest_folder):
            shutil.rmtree(dest_folder)
        os.makedirs(dest_folder)
        src_folder = os.path.join(DATABASE_PATH, db_id)
        shutil.copytree(src_folder, dest_folder, dirs_exist_ok=True)

        






def add_agent_setting():

    with open(JSONL_PATH, "r") as f:
        examples = [json.loads(line) for line in f]

    agent_dir_path = os.path.join('./','examples')
    
    clear_folder(agent_dir_path)

    if not os.path.exists(agent_dir_path):
        os.makedirs(agent_dir_path)
    shutil.copy(JSONL_PATH, agent_dir_path)


    for example in tqdm(examples):
        instance_id = example['instance_id']
        example_path = os.path.join(agent_dir_path, f"{instance_id}")
        if not os.path.exists(example_path):
            os.makedirs(example_path)
        external_knowledge = example['external_knowledge']
        if external_knowledge != None:
            shutil.copy(os.path.join(DOCUMENT_PATH, external_knowledge), example_path)


    for example in tqdm(examples):
        instance_id = example['instance_id']

        if instance_id.startswith('bq') or instance_id.startswith('ga'):

            db_id = example['db']
            example_folder = f'examples/{instance_id}'
            assert os.path.exists(example_folder)
            dest_folder = os.path.join(example_folder, db_id)  # Use db_id as the folder name
            if os.path.exists(dest_folder):
                shutil.rmtree(dest_folder)
            os.makedirs(dest_folder)
            src_folder = os.path.join(DATABASE_PATH_BQ, db_id)
            shutil.copytree(src_folder, dest_folder, dirs_exist_ok=True)
        
        elif instance_id.startswith('sf'):

            db_id = example['db']
            example_folder = f'examples/{instance_id}'
            assert os.path.exists(example_folder)
            dest_folder = os.path.join(example_folder, db_id)  # Use db_id as the folder name
            if os.path.exists(dest_folder):
                shutil.rmtree(dest_folder)
            os.makedirs(dest_folder)
            src_folder = os.path.join(DATABASE_PATH_SF, db_id)
            shutil.copytree(src_folder, dest_folder, dirs_exist_ok=True)

        elif instance_id.startswith('local'):
            db_id = example['db']
            example_folder = f'examples/{instance_id}'
            dest_path = os.path.join(example_folder, f"{db_id}.sqlite")
            db_path = os.path.join(DATABASE_PATH_SQLITE, f"{db_id}.sqlite")
            shutil.copy(db_path, dest_path)



    for example in tqdm(examples):
        instance_id = example['instance_id']
        credential_path_sf = 'snowflake_credential.json'
        credential_path_bq = 'bigquery_credential.json'

        if instance_id.startswith('bq') or instance_id.startswith('ga'):

            folder_path = f'examples/{instance_id}'
            target_credential_path = os.path.join(folder_path, credential_path_bq)

            if os.path.exists(target_credential_path):
                os.remove(target_credential_path)

            shutil.copy(credential_path_bq, target_credential_path)
        
        elif instance_id.startswith('sf'):

            folder_path = f'examples/{instance_id}'
            target_credential_path = os.path.join(folder_path, credential_path_sf)

            if os.path.exists(target_credential_path):
                os.remove(target_credential_path)

            shutil.copy(credential_path_sf, target_credential_path)
        





if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Setup for Spider 2.0-lite")

    args = parser.parse_args()

    add_agent_setting()

