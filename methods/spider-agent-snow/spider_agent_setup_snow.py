import os
import json
import shutil
import zipfile
import argparse

JSONL_PATH = '../../spider2-snow/spider2-snow.jsonl'
DATABASE_PATH = '../../spider2-snow/resource/databases/'
DOCUMENT_PATH = '../../spider2-snow/resource/documents'


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

        






def add_snowflake_agent_setting():

    with open(JSONL_PATH, "r") as f:
        examples = [json.loads(line) for line in f]

    snowflake_agent_dir_path = os.path.join('./','examples')
    
    clear_folder(snowflake_agent_dir_path)

    if not os.path.exists(snowflake_agent_dir_path):
        os.makedirs(snowflake_agent_dir_path)
    shutil.copy(JSONL_PATH, snowflake_agent_dir_path)


    for example in examples:
        instance_id = example['instance_id']
        example_path = os.path.join(snowflake_agent_dir_path, f"{instance_id}")
        if not os.path.exists(example_path):
            os.makedirs(example_path)
        external_knowledge = example['external_knowledge']
        if external_knowledge != None:
            shutil.copy(os.path.join(DOCUMENT_PATH, external_knowledge), example_path)





if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Setup for Spider 2.0")
    parser.add_argument("--snowflake", action="store_true", help="Setup Snowflake")
    parser.add_argument("--add_schema", action="store_true", help="Add schema")

    args = parser.parse_args()

    add_snowflake_agent_setting()

    setup_snowflake()


    setup_add_schema(args)

