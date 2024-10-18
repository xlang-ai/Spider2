import argparse
import os
import json
from eval_utils import number_match, string_match, table_match, duckdb_match, execute_process, get_bigquery_sql_result,tables_match
from tqdm import tqdm
from typing import List, Union



from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError
import matplotlib.pyplot as plt
SCOPES = ["https://www.googleapis.com/auth/spreadsheets"]
SPREADSHEET_ID = "1f1c67Zhtapr6rcwR4n591VHv3ywcM2Ioy1ZY-FvwlE4"
import uuid
random_uuid = uuid.uuid4()


CLIENT_SECRETS = 'client_secret.json'
CREDENTIALS = 'credentials.json'


if os.path.exists(CREDENTIALS):
    creds = Credentials.from_authorized_user_file(CREDENTIALS, SCOPES)
if not creds or not creds.valid:
    if creds and creds.expired and creds.refresh_token:
        creds.refresh(Request())
    else:
        flow = InstalledAppFlow.from_client_secrets_file(
            CLIENT_SECRETS, SCOPES
        )
        creds = flow.run_local_server(port=0)
    # Save the credentials for the next run
    with open(CREDENTIALS, "w") as token:
        token.write(creds.to_json())
try:
    service = build("sheets", "v4", credentials=creds)
    # Call the Sheets API
    sheet = service.spreadsheets()
except HttpError as err:
    print(f'HTTPError while getting google sheet: {err}')


def get_id_doc():
    id_dict = {}
    table_names = ["Bigquery", "GA4", "Local", "Snowflake"]
    character="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    
    for table_name in table_names:  
        response = sheet.values().get(spreadsheetId=SPREADSHEET_ID, range=f'{table_name}!A:Z').execute()  
        values = response.get("values", [])  
        column_names = values[0]  
        
        toks_index = column_names.index('#Toks')  
        
        col = character[toks_index] 
        
        for i in tqdm(range(1, len(values)), desc=f'Processing {table_name}', unit='row'):  
            example = {}  
            try:  
                if values[i][column_names.index('Double check')].strip() != '✅':  
                    continue  
            except:  
                continue  
            
            try:
                if values[i][column_names.index('#Toks')].strip() == '':
                    continue 
            except:
                continue
            

            instance_id = values[i][column_names.index('id')]
            doc = values[i][column_names.index('External Document')]
            toks = values[i][column_names.index('#Toks')]
            
            is_multiple = 0
            if '\n' in values[i][column_names.index('DB')]:
                is_multiple = 1
                
            path = os.path.join("../../spider2-lite/evaluation_suite/gold/sql", f"{instance_id}.sql")    
            sql_content = open(path, 'r').read()
            
            is_nested = 0
            if 'UNNEST' in sql_content:
                is_nested = 1
            
            id_dict[instance_id] = {"doc": doc, "toks": toks, "multiple": is_multiple, "nested": is_nested}

    return id_dict
    

id_dict = get_id_doc()


dbt_dict = json.load(open("dbt_difficulty.json", 'r'))

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
    

    target_instance_ids = ["airbnb002"]

    evaluation_data = [item for item in evaluation_data if item["instance_id"] not in target_instance_ids]


    
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
            results_data = [ os.path.join(result_dir,data['instance_id'], path) for path in  data['answer_or_path']]
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
    
    statistics = {  
        'bq_ga': {'count_with_score_1': 0, 'total_count': 0},  
        'sf': {'count_with_score_1': 0, 'total_count': 0},  
        'local': {'count_with_score_1': 0, 'total_count': 0},  
        'bq_ga_sf': {'count_with_score_1': 0, 'total_count': 0},
        'dbt': {'count_with_score_1': 0, 'total_count': 0}
    }  
    print("##############################################################")
    # Iterate through the output_list to gather statistics  
    for item in output_list:  
        instance_id = item['instance_id']  
        score = item['score']  

        if instance_id.startswith(('bq', 'ga')):  
            statistics['bq_ga']['total_count'] += 1  
            if score == 1:  
                statistics['bq_ga']['count_with_score_1'] += 1  
            
            statistics['bq_ga_sf']['total_count'] += 1  
            if score == 1:  
                statistics['bq_ga_sf']['count_with_score_1'] += 1  

        elif instance_id.startswith('sf'):  
            statistics['sf']['total_count'] += 1  
            if score == 1:  
                statistics['sf']['count_with_score_1'] += 1  
                
            statistics['bq_ga_sf']['total_count'] += 1  
            if score == 1:  
                statistics['bq_ga_sf']['count_with_score_1'] += 1  

        elif instance_id.startswith('local'):  
            statistics['local']['total_count'] += 1  
            if score == 1:  
                statistics['local']['count_with_score_1'] += 1  
        elif not any(instance_id.startswith(item) for item in ('bq', 'ga', 'sf', 'local')):
            statistics['dbt']['total_count'] += 1  
            if score == 1:  
                statistics['dbt']['count_with_score_1'] += 1

    # Calculate percentages and output the results for statistics  
    output_lines = []  
    for key in statistics:  
        total = statistics[key]['total_count']  
        count_with_score_1 = statistics[key]['count_with_score_1']  
        percentage = (count_with_score_1 / total * 100) if total > 0 else 0  # Avoid division by zero  
        output_lines.append(f"{key}: Success Number: {count_with_score_1}, Total count: {total}, Success Rate: {percentage:.2f}%")  

    print("\n".join(output_lines))  

    # Initialize statistics for doc presence classification  
    statistics = {  
        'doc_present': {'count_with_score_1': 0, 'total_count': 0},  
        'doc_absent': {'count_with_score_1': 0, 'total_count': 0}  
    }  
    
    nested_statistics = {  
        'nested_present': {'count_with_score_1': 0, 'total_count': 0},  
        'nested_absent': {'count_with_score_1': 0, 'total_count': 0}  
    }  
    
    multiple_statistics = {  
        'multiple_present': {'count_with_score_1': 0, 'total_count': 0},  
        'multiple_absent': {'count_with_score_1': 0, 'total_count': 0}  
    }  



    # Initialize toks classifications  
    toks_classification = {  
        'toks_less_80': {'count_with_score_1': 0, 'total_count': 0},  
        'toks_80_to_160': {'count_with_score_1': 0, 'total_count': 0},  
        'toks_more_160': {'count_with_score_1': 0, 'total_count': 0},  
    }  
    
    answer_statistics = {  
        'answer_string': {'count_with_score_1': 0, 'total_count': 0},  
        'answer_table': {'count_with_score_1': 0, 'total_count': 0}   
    }  

    dbt_statistics = {  
        'is_dbt': {'count_with_score_1': 0, 'total_count': 0},  
        'not_dbt': {'count_with_score_1': 0, 'total_count': 0}   
    }  
    
    total_number = len(output_list)
    # Iterate through output_list to classify based on score and doc presence  
    for item in output_list:  
        instance_id = item['instance_id']  
        score = item['score']  
        
        if instance_id in id_dict:  
            attributes = id_dict[instance_id]  
            doc = attributes['doc']  
            toks = int(attributes['toks'])  # Convert toks to integer for comparisons  
            nested = attributes['nested']  
            multiple = attributes['multiple']  
            
            
            # Classification based on doc presence  
            if doc:  
                statistics['doc_present']['total_count'] += 1  
                if score == 1:  
                    statistics['doc_present']['count_with_score_1'] += 1  
            else:  
                statistics['doc_absent']['total_count'] += 1  
                if score == 1:  
                    statistics['doc_absent']['count_with_score_1'] += 1  
            
            # Classification based on toks value  
            if toks < 80:  
                toks_classification['toks_less_80']['total_count'] += 1  
                if score == 1:  
                    toks_classification['toks_less_80']['count_with_score_1'] += 1  
            elif 80 <= toks < 160:  
                toks_classification['toks_80_to_160']['total_count'] += 1  
                if score == 1:  
                    toks_classification['toks_80_to_160']['count_with_score_1'] += 1  
            else:  # toks >= 160  
                toks_classification['toks_more_160']['total_count'] += 1  
                if score == 1:  
                    toks_classification['toks_more_160']['count_with_score_1'] += 1   
            
            # Nested statistics  
            if nested:  
                nested_statistics['nested_present']['total_count'] += 1  
                if score == 1:  
                    nested_statistics['nested_present']['count_with_score_1'] += 1  
            else:  
                nested_statistics['nested_absent']['total_count'] += 1  
                if score == 1:  
                    nested_statistics['nested_absent']['count_with_score_1'] += 1  
            
            # Multiple statistics  
            if multiple:  
                multiple_statistics['multiple_present']['total_count'] += 1  
                if score == 1:  
                    multiple_statistics['multiple_present']['count_with_score_1'] += 1  
            else:  
                multiple_statistics['multiple_absent']['total_count'] += 1  
                if score == 1:  
                    multiple_statistics['multiple_absent']['count_with_score_1'] += 1 
            
            # if answer_format:
            #     answer_statistics['multiple_present']['total_count'] += 1  
            #     if score == 1:  
            #         answer_statistics['multiple_present']['count_with_score_1'] += 1  
            # else:  
            #     answer_statistics['multiple_absent']['total_count'] += 1  
            #     if score == 1:  
            #         answer_statistics['multiple_absent']['count_with_score_1'] += 1   

            if item['answer_or_path'].endswith('.csv'):
                answer_statistics['answer_table']['total_count'] += 1  
                if score == 1:  
                    answer_statistics['answer_table']['count_with_score_1'] += 1  
            else:
                answer_statistics['answer_string']['total_count'] += 1  
                if score == 1:  
                    answer_statistics['answer_string']['count_with_score_1'] += 1
        else:
            if dbt_dict[instance_id] == 'Easy':  
                toks_classification['toks_less_80']['total_count'] += 1  
                if score == 1:  
                    toks_classification['toks_less_80']['count_with_score_1'] += 1  
            elif dbt_dict[instance_id] == 'Medium':  
                toks_classification['toks_80_to_160']['total_count'] += 1  
                if score == 1:  
                    toks_classification['toks_80_to_160']['count_with_score_1'] += 1  
            else:  # toks >= 160  
                toks_classification['toks_more_160']['total_count'] += 1  
                if score == 1:  
                    toks_classification['toks_more_160']['count_with_score_1'] += 1 

                



    print("##############################################################")  

    # Calculate percentages and output the results for statistics  
    output_lines = []  
    for key in statistics:  
        total = statistics[key]['total_count']  
        count_with_score_1 = statistics[key]['count_with_score_1']  
        percentage = (count_with_score_1 / total * 100) if total > 0 else 0  # Avoid division by zero  
        output_lines.append(f"{key}: Success Number: {count_with_score_1}, Total count: {total}, Percentage: {total/total_number*100:.2f}%, Success Rate: {percentage:.2f}%")  

    print("\n".join(output_lines))   
    print(f"Total Statistics Count: {sum(statistics[key]['total_count'] for key in statistics)}")  # Print total count for statistics  

    print("##############################################################")  

    # Calculate percentages and output the results for toks classification  
    output_lines = []  
    for key in toks_classification:  
        total = toks_classification[key]['total_count']  
        count_with_score_1 = toks_classification[key]['count_with_score_1']  
        percentage = (count_with_score_1 / total * 100) if total > 0 else 0  # Avoid division by zero  
        output_lines.append(f"{key}: Success Number: {count_with_score_1}, Total count: {total}, Percentage: {total/total_number*100:.2f}%, Success Rate: {percentage:.2f}%")  

    print("\n".join(output_lines))   
    print(f"Total Toks Classification Count: {sum(toks_classification[key]['total_count'] for key in toks_classification)}")  # Print total count for toks classification  

    print("##############################################################")  

    # Calculate percentages and output the results for nested statistics  
    output_lines = []  
    for key in nested_statistics:  
        total = nested_statistics[key]['total_count']  
        count_with_score_1 = nested_statistics[key]['count_with_score_1']  
        percentage = (count_with_score_1 / total * 100) if total > 0 else 0  # Avoid division by zero  
        output_lines.append(f"{key}: Success Number: {count_with_score_1}, Total count: {total}, Percentage: {total/total_number*100:.2f}%, Success Rate: {percentage:.2f}%")  

    print("\n".join(output_lines))   
    print(f"Total Nested Statistics Count: {sum(nested_statistics[key]['total_count'] for key in nested_statistics)}")  # Print total count for nested statistics  

    print("##############################################################")  

    # Calculate percentages and output the results for multiple statistics  
    output_lines = []  
    for key in multiple_statistics:  
        total = multiple_statistics[key]['total_count']  
        count_with_score_1 = multiple_statistics[key]['count_with_score_1']  
        percentage = (count_with_score_1 / total * 100) if total > 0 else 0  # Avoid division by zero  
        output_lines.append(f"{key}: Success Number: {count_with_score_1}, Total count: {total}, Percentage: {total/total_number*100:.2f}%, Success Rate: {percentage:.2f}%")  

    print("\n".join(output_lines))   
    print(f"Total Multiple Statistics Count: {sum(multiple_statistics[key]['total_count'] for key in multiple_statistics)}")  # Print total count for multiple statistics  

    print("##############################################################")  

    # Calculate percentages and output the results for answer statistics  
    output_lines = []  
    for key in answer_statistics:  
        total = answer_statistics[key]['total_count']  
        count_with_score_1 = answer_statistics[key]['count_with_score_1']  
        percentage = (count_with_score_1 / total * 100) if total > 0 else 0  # Avoid division by zero  
        output_lines.append(f"{key}: Success Number: {count_with_score_1}, Total count: {total}, Percentage: {total/total_number*100:.2f}%, Success Rate: {percentage:.2f}%")  

    print("\n".join(output_lines))   
    print(f"Total Answer Statistics Count: {sum(answer_statistics[key]['total_count'] for key in answer_statistics)}")  # Print total count for answer statistics
        
    
    print("##############################################################")  
    output_lines = []
    for key in dbt_statistics:
        total = dbt_statistics[key]['total_count']
        count_with_score_1 = dbt_statistics[key]['count_with_score_1']
        percentage = (count_with_score_1 / total * 100) if total > 0 else 0
        output_lines.append(f"{key}: Success Number: {count_with_score_1}, Total count: {total}, Percentage: {total/total_number*100:.2f}%, Success Rate: {percentage:.2f}%")
    
    print("\n".join(output_lines))


    score = 0
    for item in output_list:
        if item['score'] == 1:
            score += 1
            # print(item['instance_id'])
    print(score / len(output_list), score, len(output_list))
    print(len(gold_dict.keys()))
    
    output_dict_jixuan = {}
    
    for item in output_list:
        output_dict_jixuan[item['instance_id']] = item['score']
    
    json.dump(output_dict_jixuan, open("output_dict.json", 'w'))
    


    

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
