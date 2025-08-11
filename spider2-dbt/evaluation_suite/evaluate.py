import argparse
import os
import json
from eval_utils import number_match, string_match, table_match, duckdb_match, execute_process, get_bigquery_sql_result,tables_match
from tqdm import tqdm
from typing import List, Union

def read_jsonl(file_path):
    data = []
    try:
        with open(file_path, 'r') as f:
            for line in f:
                data.append(json.loads(line.strip()))
    except FileNotFoundError:
        print(f"File not found: {file_path}")
    except json.JSONDecodeError as e:
        print(f"Error decoding JSON: {e}")
    return data



def run_evaluation(result_dir, gold_dir):
    gold_jsonl_files = [f for f in os.listdir(gold_dir) if f.endswith('.jsonl')]
    assert len(gold_jsonl_files) == 1 and gold_jsonl_files[0] == "spider2_eval.jsonl"
    gold_jsonl_file = os.path.join(gold_dir,gold_jsonl_files[0])
    
    result_jsonl_files = [f for f in os.listdir(result_dir) if f.endswith('.jsonl')]
    assert len(result_jsonl_files) == 1 and result_jsonl_files[0] == "results_metadata.jsonl"
    result_jsonl_file = os.path.join(result_dir,result_jsonl_files[0])
    
    gold_data = read_jsonl(gold_jsonl_file)
    result_data = read_jsonl(result_jsonl_file)

    # Create dictionaries for quick lookup by instance_id
    gold_dict = {entry['instance_id']: entry for entry in gold_data}
    result_dict = {entry['instance_id']: entry for entry in result_data}

    # Find common instance_ids and merge data
    common_instance_ids = set(gold_dict.keys()).intersection(result_dict.keys())
    evaluation_data = [{**gold_dict[id], **result_dict[id]} for id in common_instance_ids]
    
    print(len(evaluation_data))
    
    total = 0
    output_list = []
    

    for data in tqdm(evaluation_data):
        output_dict = data
        eval_metadata = data['evaluation']
        
        if not isinstance(eval_metadata, list):
            eval_metadatas = [eval_metadata]
        else:
            eval_metadatas = eval_metadata
        
        score = 0
        if data['answer_type'] == 'answer':
            
            temp_scores = []
            for eval_metadata in eval_metadatas:
                # if 'temporal' in eval_metadata and eval_metadata['temporal']: 
                #     eval_metadata['parameters'] = execute_process(eval_metadata['func'], eval_metadata['parameters'], os.path.join(gold_dir, data['instance_id']))
                try:
                    if eval_metadata['func'] == 'string_match':
                        score = string_match(data['answer_or_path'], **eval_metadata['parameters'])
                    elif eval_metadata['func'] == 'number_match':
                        score = number_match(data['answer_or_path'], **eval_metadata['parameters'])
                    temp_scores.append(score)
                except:
                    import pdb; pdb.set_trace()
            score = max(temp_scores)
                
                        
        elif data['answer_type'] == 'file':
            # postprocess for answers of SQL files
            if data['answer_or_path'].endswith('.sql'):
                sql_query = open(os.path.join(result_dir,data['instance_id'], data['answer_or_path']), 'r').read()
                get_bigquery_sql_result(sql_query, is_save=True, save_dir=os.path.join(result_dir, data['instance_id']), save_file='pred_result.csv')
                data['answer_or_path'] = 'pred_result.csv'

            for eval_metadata in eval_metadatas:
                # if 'temporal' in eval_metadata and eval_metadata['temporal']: 
                #     eval_metadata['parameters'] = execute_process(eval_metadata['func'], eval_metadata['parameters'], os.path.join(gold_dir, data['instance_id']))

                if eval_metadata['func'] == 'table_match':
                    if isinstance(eval_metadata['parameters']['gold'], str):
                        eval_metadata['parameters']['gold'] = os.path.join(gold_dir, data['instance_id'], eval_metadata['parameters']['gold'])
                    elif isinstance(eval_metadata['parameters']['gold'], List):
                        eval_metadata['parameters']['gold'] = [os.path.join(gold_dir, data['instance_id'], gold_file) for gold_file in eval_metadata['parameters']['gold']]
                    try:
                        score = table_match(os.path.join(result_dir,data['instance_id'], data['answer_or_path']), **eval_metadata['parameters'])
                    except:
                        print(f"ERROR: {data['instance_id']}")
                        score = 0
                elif eval_metadata['func'] == 'duckdb_match':
                    eval_metadata['parameters']['gold'] = os.path.join(gold_dir, data['instance_id'], eval_metadata['parameters']['gold'])
                    try:
                        score = duckdb_match(os.path.join(result_dir,data['instance_id'], data['answer_or_path']), **eval_metadata['parameters'])    
                    except:
                        score = 0

            
        elif data['answer_type'] == 'files':
            eval_metadata['parameters']['gold'] = [ os.path.join(gold_dir, data['instance_id'], gold_item) for gold_item in eval_metadata['parameters']['gold']   ]
            results_data = [os.path.join(result_dir,data['instance_id'], path) for path in  data['answer_or_path']]
            score = tables_match(results_data, **eval_metadata['parameters'])


        if score == 1:
            print(data)   
            # import pdb; pdb.set_trace()   
                        
        output_dict['score'] = score
        output_list.append(output_dict)
        
                
    score = 0
    for item in output_list:
        if item['score'] == 1:
            score += 1
            print(item['instance_id'])
    print(score / len(output_list), score, len(output_list))
    


    

def parse_arguments():
    parser = argparse.ArgumentParser(description="Run evaluations for NLP models.")
    parser.add_argument("--result_dir", type=str, required=True, help="Result directory")
    parser.add_argument("--gold_dir", type=str, default="./gold", help="Directory containing gold standard files")
    return parser.parse_args()

def main():
    args = parse_arguments()
    run_evaluation(args.result_dir, args.gold_dir)

if __name__ == "__main__":
    main()
