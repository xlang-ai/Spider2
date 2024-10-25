# import debugpy; debugpy.connect(('127.0.0.1', 5688))
import argparse
import os
import torch
import json
import time

from transformers import AutoModelForCausalLM, AutoTokenizer
from utils.load_sft_dataset import SFTSQLGenerationDataset
from utils.db_utils import check_sql_executability, detect_special_char
from torch.utils.data import DataLoader
from tqdm import tqdm


def post_process(sql, schema_items, instance_id):
    sql = sql.replace("\n", " ")
    for table in schema_items:
        for column_name in table["column_names"]:
            if detect_special_char(column_name) and column_name in sql:
                sql = sql.replace(column_name, "`"+column_name+"`")

    while "``" in sql:
        sql = sql.replace("``", "`")

    if len(sql.split(';')) == 1:
        print('>>> warning: SQL without semicolon:', instance_id)

    sql = sql.split(';')[0]  # 0923: for bad instruction following, output so many useless things after the first SQL

    return sql

def text2sql_func(model, inputs, tokenizer, max_new_tokens):
    input_length = inputs["input_ids"].shape[1]
    
    with torch.no_grad():
        generate_ids = model.generate(
            **inputs,
            max_new_tokens = max_new_tokens,
            num_beams = 1,  # 4
            num_return_sequences = 1  # 4
        )

    # print(tokenizer.decode(generate_ids[0]))
    generated_sqls = tokenizer.batch_decode(generate_ids[:, input_length:], skip_special_tokens = True, clean_up_tokenization_spaces = False)
    # print(generated_sqls)

    return generated_sqls

if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument('--llm_path', type = str)
    parser.add_argument('--sic_path', type = str)
    parser.add_argument('--table_num', type = int, default = 6)
    parser.add_argument('--column_num', type = int, default = 10)

    parser.add_argument('--dataset_path', type = str)

    parser.add_argument('--max_tokens', type = int, default = 4096)
    parser.add_argument('--max_new_tokens', type = int, default = 256)    

    parser.add_argument("--use_external_knowledge", action="store_false", default=True)
    parser.add_argument("--use_few_shot", action="store_true", default=False)
    parser.add_argument("--use_special_function", action="store_true", default=False)
    parser.add_argument("--use_plan", action="store_true", default=False)

    parser.add_argument('--dev', default='spider2_dev', type=str, help='the name of dev file')
    parser.add_argument("--comment", type=str, default='')
    parser.add_argument("--gpu_id", type=int, default=0)
    parser.add_argument("--override", action='store_true', default=False)
    args = parser.parse_args()
    print(args)
    os.environ["CUDA_VISIBLE_DEVICES"] = str(args.gpu_id)


    max_tokens = args.max_tokens
    max_new_tokens = args.max_new_tokens

    tokenizer = AutoTokenizer.from_pretrained(args.llm_path)
    raw_dataset = json.load(open(args.dataset_path))
    eval_set = SFTSQLGenerationDataset(
        args.dataset_path,
        tokenizer,
        # max_tokens,
        max_tokens - max_new_tokens,  # make sure no error. for instance: 8192 - 1000
        "eval",
        args.table_num,
        args.column_num,
        args.sic_path,
        args
    ) 

    # note: current, we only support batch size = 1
    dataloader = DataLoader(eval_set, batch_size = 1)
    model = AutoModelForCausalLM.from_pretrained(args.llm_path, device_map = "auto", torch_dtype = torch.float16)
    model.eval()
    start_time = time.time()
    predicted_sqls = []

    submit_folder = os.path.join("postprocessed_data", f"{args.comment}-{args.dev}", f"{args.dev}-pred-sqls")
    os.makedirs(submit_folder, exist_ok=True)
    existing_instance_ids = {f.split('.')[0].split('@')[0] for f in os.listdir(submit_folder) if f.endswith('.sql')}

    processed_number = 0
    for idx, (raw_data, batch_data) in enumerate(tqdm(zip(raw_dataset, dataloader))):
        instance_id = raw_data.get("instance_id", f"instance_{idx}")
        if not args.override and instance_id in existing_instance_ids:
            continue 

        processed_number += 1

        # write prompt to file
        instance_folder = os.path.join(submit_folder, '../prompts')
        os.makedirs(instance_folder, exist_ok=True)
        prompt_file_path = os.path.join(instance_folder, f"{instance_id}.txt")
        with open(prompt_file_path, 'w', encoding='utf-8') as file:
            file.write(
                # the truncated prompt
                ''.join(tokenizer.batch_decode(batch_data['input_ids'][0], skip_special_tokens=True))
            )
        with open(prompt_file_path.replace('.txt', '.json'), 'w', encoding='utf-8') as file:
            json.dump({
                'input_length': len(batch_data['input_ids'][0])
            }, file)

        for key in batch_data:
            batch_data[key] = batch_data[key].to(model.device)
        generated_sqls = text2sql_func(model, batch_data, tokenizer, max_new_tokens)
        generated_sqls = [post_process(generated_sql, raw_data["schema"]["schema_items"], instance_id) for generated_sql in generated_sqls]

        '''
        final_generated_sql = None
        for generated_sql in generated_sqls:
            execution_error = check_sql_executability(generated_sql, raw_data["db_path"])
            if execution_error is None: # the generated sql has no execution errors, we will return it as the final generated sql
                final_generated_sql = generated_sql
                break

        if final_generated_sql is None:
            if generated_sqls[0].strip() != "":
                final_generated_sql = generated_sqls[0]
            else:
                final_generated_sql = "SQL placeholder"
        '''

        final_generated_sql = generated_sqls[0] if generated_sqls[0].strip() != "" else "SQL placeholder"
        print(final_generated_sql)
        # predicted_sqls.append(final_generated_sql)

        # save SQL
        sql_file_path = os.path.join(submit_folder, f"{instance_id}@0.sql")
        with open(sql_file_path, "w", encoding='utf-8') as submit_file:
            submit_file.write(final_generated_sql)

    end_time = time.time()
    print("LLM name: {} | Total time: {}s | Example number: {} | Average time: {}s".format(
        args.llm_path, 
        end_time - start_time,
        processed_number,
        (end_time - start_time) / len(raw_dataset)
        )
    )

    # for idx, (data, predicted_sql) in enumerate(zip(raw_dataset, predicted_sqls)):
    #     instance_id = data.get("instance_id", f"instance_{idx}")
    #     sql_file_path = os.path.join(submit_folder, f"{instance_id}.sql")
    #     with open(sql_file_path, "w", encoding='utf-8') as submit_file:
    #         submit_file.write(predicted_sql)

    # print(f"SQL files saved in {submit_folder}")

