
import argparse

import os
import json
import shutil


def copy_folder(src, dest, files_to_copy=None):
    """
    Copies a folder or specified files to a destination path. 
    If the destination path exists, it will be cleared first.

    :param src: Source folder path
    :param dest: Destination folder path
    :param files_to_copy: List or string of files to copy, or None to copy the entire folder
    """
    # Clear the destination folder if it exists
    if os.path.exists(dest):
        shutil.rmtree(dest)
    os.makedirs(dest)
    
    if files_to_copy is None:
        shutil.copytree(src, dest, dirs_exist_ok=True)
    else:
        # Copy specified files
        if isinstance(files_to_copy, str):
            files_to_copy = [files_to_copy]
        
        os.makedirs(dest, exist_ok=True)
        for file in files_to_copy:
            full_file_path = os.path.join(src, file)
            if os.path.exists(full_file_path):
                if os.path.isdir(full_file_path):
                    # If the item is a directory, use copytree
                    shutil.copytree(full_file_path, os.path.join(dest, file), dirs_exist_ok=True)
                else:
                    # Otherwise, use copy for files
                    shutil.copy(full_file_path, dest)
            else:
                print(f"File {file} does not exist in the source path {src}")



def postprocess(args):
    
    output_dir = os.path.join(os.path.join(args.all_results_path, args.experiment_suffix))
    
    submission_dir = args.results_folder_name
    if not os.path.exists(submission_dir):
        os.makedirs(submission_dir)
        
        
    results_metadata = []
        
    for instance_id in os.listdir(output_dir):
        if not os.path.isdir(os.path.join(output_dir, instance_id)):
            continue
        json_file_path = os.path.join(output_dir, instance_id, "spider", "result.json")
        try:
            with open(json_file_path, 'r') as file:
                instance_result_data = json.load(file)
        except FileNotFoundError:
            print(f"Error: File not found - {json_file_path}")
            continue
        
        result_folder_root_path = os.path.join(output_dir, instance_id)
        answer_or_path = instance_result_data['result']
        
        if answer_or_path.startswith('/workspace'):
            answer_or_path = answer_or_path.replace('/workspace/','')

        
        if answer_or_path == '':
            results_metadata.append({'instance_id': instance_id, 'answer_or_path': '', 'answer_type': 'answer'})
            continue        
        elif os.path.exists(os.path.join(result_folder_root_path,answer_or_path)):
            results_metadata.append({'instance_id': instance_id, 'answer_or_path': answer_or_path, 'answer_type': 'file'})
            try:
                copy_folder(result_folder_root_path, os.path.join(submission_dir, instance_id), files_to_copy=answer_or_path)
            except:
                import pdb; pdb.set_trace()
        elif not os.path.exists(os.path.join(result_folder_root_path,answer_or_path)):
            results_metadata.append({'instance_id': instance_id, 'answer_or_path': answer_or_path, 'answer_type': 'answer'})
    
    with open(os.path.join(submission_dir, 'results_metadata.jsonl'), 'w') as file:
        for entry in results_metadata:
            file.write(json.dumps(entry) + '\n')    
        
        
        


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Run evaluations for NLP models.")
    parser.add_argument("--all_results_path", type=str, default="output", help="Result directory")
    parser.add_argument("--experiment_suffix", type=str, default="gpt-4o-test1", help="Result directory")
    parser.add_argument("--results_folder_name", type=str, default="../../spider2/evaluation_suite/gpt-4-try1", help="Directory containing gold standard files")
    args = parser.parse_args()
    postprocess(args)