# import debugpy; debugpy.connect(("127.0.0.1", 5690))
import argparse
import os
import json
import tiktoken
import openai
from tqdm import tqdm
from torch.utils.data import DataLoader
from multiprocessing import Pool, set_start_method

from llm.chatgpt import init_chatgpt, ask_llm
from utils.enums import LLM
from utils.post_process import process_duplication, get_sqls


def process_batch(batch, submit_folder, db_ids, args, i, 
    openai_api_key, openai_group_id, model):
    """Function to process each batch in parallel."""

    # cost recorded
    os.makedirs(os.path.join(submit_folder, "../cost"), exist_ok=True)
    with open(os.path.join(submit_folder, "../cost", f"{batch['instance_id'][0]}.json"), "w") as submit_file:
        prompt = batch["prompt"][0]
        prompt_tokens = len(tiktoken.get_encoding("cl100k_base").encode(prompt))
        json.dump(
            {
                "prompt": prompt,
                "prompt_tokens": prompt_tokens, 
                "cost": prompt_tokens * 5e-6  # USD
            },
            submit_file)

    # return  # count cost only

    # init openai api
    init_chatgpt(args.openai_api_key, args.openai_group_id, args.model)

    if args.post_mode == 'consistency-from-generated-pass@n':  # load the saved sql from the output of pass@n
        cur_db_ids = db_ids[i * args.batch_size: (i+1) * args.batch_size]
        results = []
        for db_id, instance_id in zip(cur_db_ids, batch["instance_id"]):
            result = {
                'db_id': db_id,
                'p_sqls': [],
                'instance_id': instance_id
            }
            for n in range(args.n):
                sql_file_path = os.path.join(submit_folder, f"{instance_id}@{n}.sql")
                with open(sql_file_path, "r") as sql_file:
                    sql_content = sql_file.read().strip()
                    result['p_sqls'].append(sql_content)

            final_sql = get_sqls(result, args.n, args.db_dir, instance_id)
            with open(os.path.join(submit_folder, f"{instance_id}.sql"), "w") as submit_file:
                submit_file.write(final_sql)
        return

    try:
        res = ask_llm(args.model, batch["prompt"], args.temperature, args.n, args.max_tokens)
    except openai.error.InvalidRequestError:
        print(f"The {i}-th question has too much tokens! Return \"SELECT\" instead")
        res = {"response": [["SELECT" for _ in range(args.n)]]}  # hard-code for batch_size=1

    if args.n == 1: 
        assert len(res["response"]) == args.batch_size == 1
        sql = res["response"][0][0]
        instance_id = batch["instance_id"][0]
        sql = " ".join(sql.replace("\n", " ").split())
        sql = process_duplication(sql)
        with open(os.path.join(submit_folder, f"{instance_id}@0.sql"), "w") as submit_file:
            submit_file.write(sql)
    else:
        results = []
        cur_db_ids = db_ids[i * args.batch_size: (i+1) * args.batch_size]
        for sqls, db_id, instance_id in zip(res["response"], cur_db_ids, batch["instance_id"]):  # dummy loop, only excute once
            processed_sqls = []
            for sql in sqls:
                sql = " ".join(sql.replace("\n", " ").split())
                sql = process_duplication(sql)

                processed_sqls.append(sql)
            result = {
                'db_id': db_id,
                'p_sqls': processed_sqls,
                'instance_id': instance_id
            }

            if args.post_mode == 'pass@n':
                for i in range(args.n):
                    file_name = f"{instance_id}@{i}.sql"
                    file_path = os.path.join(submit_folder, file_name)
                    with open(file_path, "w") as submit_file:
                        submit_file.write(processed_sqls[i])
            elif args.post_mode == 'consistency@n':  # exec_result based consistency
                final_sql = get_sqls(result, args.n, args.db_dir, instance_id) 
                with open(os.path.join(submit_folder, f"{instance_id}.sql"), "w") as submit_file:
                    submit_file.write(final_sql)
            else:
                raise NotImplementedError


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--question", type=str)
    parser.add_argument("--openai_api_key", type=str)
    parser.add_argument("--openai_group_id", type=str, default=None)
    parser.add_argument("--model", type=str, choices=[LLM.TEXT_DAVINCI_003, 
                                                      LLM.GPT_35_TURBO,
                                                      LLM.GPT_35_TURBO_0613,
                                                      LLM.GPT_35_TURBO_16K,
                                                      LLM.GPT_4, 
                                                      LLM.GPT_4o,
                                                      LLM.GPT_4o_0806,
                                                      LLM.GPT_o1],
                        default=LLM.GPT_35_TURBO)

    parser.add_argument("--temperature", type=float, default=0)
    parser.add_argument("--batch_size", type=int, default=1)
    parser.add_argument("--n", type=int, default=1)
    parser.add_argument("--db_dir", type=str, default="../../resource/databases/spider2-localdb")
    parser.add_argument('--max_tokens', type=int, default=1000)
    parser.add_argument('--post_mode', type=str, choices=['pass@n', 'consistency@n', 'consistency-from-generated-pass@n', None], default=None)
    parser.add_argument("--is_sql_debug", action="store_true", default=False)
    parser.add_argument("--processes", type=int, default=120)  # New argument for specifying the number of processes
    parser.add_argument("--override", action="store_true")
    args = parser.parse_args()


    if args.is_sql_debug:
        QUESTION_FILE = "debug_questions.json"
    else:
        QUESTION_FILE = "questions.json"

    # check args
    assert args.model in LLM.BATCH_FORWARD or \
           args.model not in LLM.BATCH_FORWARD and args.batch_size == 1, \
        f"{args.model} doesn't support batch_size > 1"

    # load ids that already predicted
    DEBUG_PREFIX = "SQL_DEBUG_" if args.is_sql_debug else ""
    submit_folder = os.path.join(args.question, f'{DEBUG_PREFIX}RESULTS_MODEL-{args.model}-SQL')
    os.makedirs(submit_folder, exist_ok=True)

    if args.override:
        pred_ids = set()
    else:
        pred_ids = [file.split(".")[0].split("@")[0] for file in os.listdir(submit_folder) if file.endswith(".sql")]
        pred_ids = set(pred_ids)
    questions_json = json.load(open(os.path.join(args.question, QUESTION_FILE), "r"))
    questions = [{"prompt": item["prompt"], "instance_id": item["instance_id"]} for item in questions_json["questions"] \
        if item["instance_id"] not in pred_ids]
    db_ids = [item["db_id"] for item in questions_json["questions"] \
        if item["instance_id"] not in pred_ids]

    question_loader = DataLoader(questions, batch_size=args.batch_size, shuffle=False, drop_last=False)

    set_start_method('spawn', force=True)  # Ensures that the correct start method is used for multiprocessing

    token_cnt = 0
    with Pool(processes=args.processes) as pool:
        with tqdm(total=len(question_loader)) as pbar:
            for _ in pool.starmap(process_batch, [
                (
                    batch, submit_folder, db_ids, args, i, 
                    args.openai_api_key, args.openai_group_id, args.model
                ) for i, batch in enumerate(question_loader)
            ]):
                pbar.update(1)
