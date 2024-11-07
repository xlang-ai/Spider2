
import argparse
from utils.db_utils import check_sql_executability, get_db_schema_sequence, get_matched_content_sequence, detect_special_char
import os
from transformers import AutoModelForCausalLM, AutoTokenizer
import json
import nltk
import random
import numpy as np
from schema_item_filter import SchemaItemClassifierInference, filter_schema
import torch
from tqdm import tqdm
from simcse import SimCSE
from transformers.trainer_utils import set_seed

def parse_option():
    parser = argparse.ArgumentParser()
    parser.add_argument('--llm_path', type = str)
    parser.add_argument('--sic_path', type = str)
    parser.add_argument('--table_num', type = int, default = 5)
    parser.add_argument('--column_num', type = int, default = 6)
    
    parser.add_argument('--dataset_path', type = str)
    parser.add_argument('--demonstration_set_path', type = str)
    parser.add_argument('--num_of_demonstrations', type = int)

    parser.add_argument('--max_tokens', type = int)
    parser.add_argument('--max_new_tokens', type = int)

    opt = parser.parse_args()

    return opt

def post_process(sql, schema_items):
    sql = sql.replace("\n", " ")
    for table in schema_items:
        for column_name in table["column_names"]:
            if detect_special_char(column_name) and column_name in sql:
                sql = sql.replace(column_name, "`"+column_name+"`")

    while "``" in sql:
        sql = sql.replace("``", "`")

    sql = sql.split(";")[0].strip() + ";"

    return sql

# extract the skeleton of the input text
def extract_skeleton(text):
    tokens_and_tags = nltk.pos_tag(nltk.word_tokenize(text))

    output_tokens = []
    for token, tag in tokens_and_tags:
        if tag in ['NN', 'NNP', 'NNS', 'NNPS', 'CD', 'SYM', 'FW', 'IN']:
            output_tokens.append("_")
        elif token in ['$', "''", '(', ')', ',', '--', '.', ':']:
            pass
        else:
            output_tokens.append(token)
    
    text_skeleton = " ".join(output_tokens)
    text_skeleton = text_skeleton.replace("_ 's", "_")
    text_skeleton = text_skeleton.replace(" 's", "'s")

    while("_ _" in text_skeleton):
        text_skeleton = text_skeleton.replace("_ _", "_")
    while("_ , _" in text_skeleton):
        text_skeleton = text_skeleton.replace("_ , _", "_")
    
    if text_skeleton.startswith("_ "):
        text_skeleton = text_skeleton[2:]
    
    return text_skeleton

def prepare_input_ids_and_attention_mask(tokenizer, input_seq, max_input_length, device):
    input_ids = tokenizer(input_seq , truncation = False)["input_ids"]

    if len(input_ids) <= max_input_length:
        input_ids = input_ids
        attention_mask = [1] * len(input_ids)
    else:
        if tokenizer.name_or_path == "THUDM/codegeex2-6b":
            input_ids = [64790, 64792] + input_ids[-(max_input_length-2):]
        else:
            input_ids = [tokenizer.bos_token_id] + input_ids[-(max_input_length-1):]

        attention_mask = [1] * max_input_length
    
    print("len(input_ids):", len(input_ids))
 
    return {
        "input_ids": torch.tensor([input_ids]).to(device), # torch.int64
        "attention_mask": torch.tensor([attention_mask]).to(device) # torch.int64
    }

def prepare_cross_domain_input_seq(opt, eval_data, demonstration_set, similarity):
    top_k_indices = sorted(range(len(similarity)), key = lambda x: similarity[x], reverse = True)[:opt.num_of_demonstrations]
    # top_k_indices = list(reversed(top_k_indices))
    # top_k_indices = random.sample(range(len(similarity)), opt.num_of_demonstrations)
    print(top_k_indices)
    print(similarity[top_k_indices])

    input_seq = ""
    for idx in top_k_indices:
        demonstration_sql = demonstration_set[idx]["sql"]
        if demonstration_sql.endswith(";"):
            demonstration_sql = demonstration_sql[:-1].strip() + " ;"
        else:
            demonstration_sql = demonstration_sql.strip() + " ;"

        input_seq += demonstration_set[idx]["schema_sequence"] + "\n" + demonstration_set[idx]["content_sequence"] + "\n" + \
            demonstration_set[idx]["text"] + "\n" + demonstration_sql + "\n\n"

    # >>>eval_data["content_sequence"] 'matched contents : None'
    # >>>eval_data["text"] 'How many singers do we have?'
    input_seq += eval_data["schema_sequence"] + "\n" + eval_data["content_sequence"] + "\n" + eval_data["text"] + "\n"
    # print(input_seq)
    # print("-"*30)

    return input_seq

def text2sql_func(model, text2sql_input_seq, tokenizer, max_tokens, max_new_tokens, eos_token_id):
    inputs = prepare_input_ids_and_attention_mask(
        tokenizer, 
        text2sql_input_seq, 
        max_tokens - max_new_tokens,
        model.device
    )

    input_length = inputs["input_ids"].shape[1]

    # check_tokenizer(tokenizer, inputs["input_ids"])

    with torch.no_grad():
        generate_ids = model.generate(
            **inputs,
            max_new_tokens = max_new_tokens,
            num_beams = 4,
            num_return_sequences = 4,
            use_cache = True,
            eos_token_id = eos_token_id
        )

    generated_sqls = tokenizer.batch_decode(generate_ids[:, input_length:], skip_special_tokens = True, clean_up_tokenization_spaces = False)

    return generated_sqls

if __name__ == "__main__":
    set_seed(42)
    opt = parse_option()
    print(opt)

    # load the evaluation set1
    eval_set = json.load(open(opt.dataset_path))
    eval_set_questions = [data["question"] for data in eval_set]
    eval_set_question_skeletons = [extract_skeleton(question) for question in eval_set_questions]

    print("length of evaluation set:", len(eval_set))

    # load the demon1stration pool
    demonstration_set = json.load(open(opt.demonstration_set_path))
    demonstration_set_questions = [data["question"] for data in demonstration_set]
    demonstration_set_question_skeletons = [extract_skeleton(question) for question in demonstration_set_questions]
    
    print("length of demonstration set:", len(demonstration_set))
    
    demonstration_set = filter_schema(demonstration_set, "train", None, opt.table_num, opt.column_num)
    sic = SchemaItemClassifierInference(opt.sic_path)
    eval_set = filter_schema(eval_set, "eval", sic, opt.table_num, opt.column_num)
    del sic
    torch.cuda.empty_cache()

    # prepare schema sequence and content sequence for each sample
    for demonstration_sample in demonstration_set:
        demonstration_sample["schema_sequence"] = get_db_schema_sequence(demonstration_sample["schema"])
        demonstration_sample["content_sequence"] = get_matched_content_sequence(demonstration_sample["matched_contents"])
    for eval_sample in eval_set:
        eval_sample["schema_sequence"] = get_db_schema_sequence(eval_sample["schema"])  
        eval_sample["content_sequence"] = get_matched_content_sequence(eval_sample["matched_contents"])

    # compute similarities between questions in the evaluation set and the demonstration pool
    simsce_model = SimCSE("/data1/yyx/llms/sup-simcse-roberta-base")
    question_similarities = simsce_model.similarity(eval_set_questions, demonstration_set_questions) 
    question_skeleton_similarities = simsce_model.similarity(eval_set_question_skeletons, demonstration_set_question_skeletons) 
    similarities = np.maximum(question_similarities, question_skeleton_similarities)
    
    del simsce_model

    tokenizer = AutoTokenizer.from_pretrained(opt.llm_path)
    model = AutoModelForCausalLM.from_pretrained(opt.llm_path, device_map = "auto", torch_dtype = torch.float16)
    model.eval()
    print(model.dtype)

    # update eos token id of the tokenizer and the model to support early stop SQL generation
    token_ids_of_example_sql = tokenizer("SELECT * FROM tables ;")["input_ids"]
    print(token_ids_of_example_sql)
    if token_ids_of_example_sql[-1] == tokenizer.eos_token_id:
        new_eos_token_id = token_ids_of_example_sql[-2]
    else:
        new_eos_token_id = token_ids_of_example_sql[-1]
    model.config.eos_token_id = new_eos_token_id
    tokenizer.eos_token_id = new_eos_token_id
    print("new_eos_token_id:", new_eos_token_id)
    print("tokenizer.decode(new_eos_token_id): '{}'".format(tokenizer.decode(new_eos_token_id)))

    max_tokens = opt.max_tokens
    max_new_tokens = opt.max_new_tokens

    print("max_tokens:", max_tokens)
    print("max_new_tokens:", max_new_tokens)

    predicted_sqls = []
    for eval_data_idx, eval_data in tqdm(enumerate(eval_set)):
        input_seq = prepare_cross_domain_input_seq(opt, eval_data, demonstration_set, similarities[eval_data_idx])
    
        if eval_data_idx < 2:
            print(input_seq)
        
        generated_sqls = text2sql_func(model, input_seq, tokenizer, max_tokens, max_new_tokens, new_eos_token_id)
        generated_sqls = [post_process(generated_sql, eval_data["schema"]["schema_items"]) for generated_sql in generated_sqls]
        
        final_generated_sql = None
        for generated_sql in generated_sqls:
            execution_error = check_sql_executability(generated_sql, eval_data["db_path"])
            if execution_error is None: # the generated sql has no execution errors, we will return it as the final generated sql
                final_generated_sql = generated_sql
                break

        if final_generated_sql is None:
            if generated_sqls[0].strip() != "":
                final_generated_sql = generated_sqls[0]
            else:
                final_generated_sql = "SQL placeholder"
        
        print(final_generated_sql)
        predicted_sqls.append(final_generated_sql)

    print("LLM name:", opt.llm_path)
    if "bird" in opt.dataset_path:
        bird_results_dict = dict()
        for idx, (data, predicted_sql) in enumerate(zip(eval_set, predicted_sqls)):
            bird_results_dict[idx] = predicted_sql + "\t----- bird -----\t" + data["db_id"]
        with open("predict_dev.json", "w", encoding = 'utf-8') as f:
            f.write(json.dumps(bird_results_dict, indent = 2, ensure_ascii = False))
        os.system("sh bird_evaluation/run_evaluation.sh {}".format("predict_dev.json"))
    elif "spider_dev" in opt.dataset_path:
        with open("pred_sqls.txt", "w", encoding = 'utf-8') as f:
            for sql in predicted_sqls:
                f.write(sql + "\n")
        print("Execution accuracy:")
        os.system('python -u test_suite_sql_eval/evaluation.py --gold ./data/sft_data_collections/spider/dev_gold.sql --pred pred_sqls.txt --db ./data/sft_data_collections/spider/database --etype exec')
        print("Test suit execution accuracy:")
        os.system('python -u test_suite_sql_eval/evaluation.py --gold ./data/sft_data_collections/spider/dev_gold.sql --pred pred_sqls.txt --db test_suite_sql_eval/test_suite_database --etype exec')
    elif "bank" in opt.dataset_path:
        with open("pred_sqls.txt", "w", encoding = 'utf-8') as f:
            for sql in predicted_sqls:
                f.write(sql + "\n")
        print("Execution accuracy:")
        os.system('python -u evaluate_ex.py --pred pred_sqls.txt --gold {} --db ./data/sft_data_collections/domain_datasets/databases/Bank_Financials/Bank_Financials.sqlite'.format(opt.dataset_path))
    elif "aminer" in opt.dataset_path:
        with open("pred_sqls.txt", "w", encoding = 'utf-8') as f:
            for sql in predicted_sqls:
                f.write(sql + "\n")
        print("Execution accuracy:")
        os.system('python -u evaluate_ex.py --pred pred_sqls.txt --gold {} --db ./data/sft_data_collections/domain_datasets/databases/Aminer_Simplified/Aminer_Simplified.sqlite'.format(opt.dataset_path))