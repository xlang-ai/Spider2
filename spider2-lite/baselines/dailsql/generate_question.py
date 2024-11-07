# import debugpy; debugpy.connect(("127.0.0.1", 5688))
"""
Generate questions for LLMs and save it as a task
"""
import argparse
import os
import os.path as osp
import sys
import json
from prompt.prompt_builder import prompt_factory
from utils.data_builder import Spider2CForDailSQL_Dataset
from utils.enums import REPR_TYPE, EXAMPLE_TYPE, SELECTOR_TYPE, LLM
from utils.utils import cost_estimate
import multiprocessing as mp
from multiprocessing import Pool
from tqdm import tqdm

proj_dir = osp.dirname(osp.abspath(__file__))

sys.path.append("./")


def process_question(question_json, args, cross_domain):
    try:
        # assert 1 != 1, "This is a test"
        question_format = prompt.format(target=question_json,
                                        max_seq_len=args.max_seq_len,
                                        max_ans_len=args.max_ans_len,
                                        scope_factor=args.scope_factor,
                                        cross_domain=cross_domain, 
                                        args=args)
        question_format['instance_id'] = question_json['instance_id'] 
        return question_format, question_format["prompt_tokens"]
    except Exception as e:
        error = f"Error occured in process_question: {str(e)}"
        print(error)
        return error

def collect_result(result):
    global questions, token_cnt, pbar
    question_format, prompt_tokens = result
    questions.append(question_format)
    token_cnt += prompt_tokens
    pbar.update(1)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--dev', default='spider2_dev', type=str, help='the name of dev file')
    parser.add_argument("--model", type=str)
    parser.add_argument("--split", type=str, choices=["train", "test"], default="test")
    parser.add_argument("--k_shot", type=int, default=0, help="Number of examples")
    parser.add_argument("--prompt_repr", type=str, choices=[REPR_TYPE.CODE_REPRESENTATION,
                                                            REPR_TYPE.TEXT_REPRESENTATION,
                                                            REPR_TYPE.OPENAI_DEMOSTRATION,
                                                            REPR_TYPE.BASIC,
                                                            REPR_TYPE.ALPACA_SFT,
                                                            REPR_TYPE.OPENAI_DEMOSTRATION_WFK,
                                                            REPR_TYPE.BASIC_WOFK,
                                                            REPR_TYPE.TEXT_REPRESENTATION_WFK,
                                                            REPR_TYPE.ALPACA_SFT_WFK,
                                                            REPR_TYPE.OPENAI_DEMOSTRATION_WORULE,
                                                            REPR_TYPE.CODE_REPRESENTATION_WRULE,
                                                            REPR_TYPE.ALPACA_SFT_WRULE,
                                                            REPR_TYPE.TEXT_REPRESENTATION_WRULE,
                                                            REPR_TYPE.CODE_REPRESENTATION_COT,
                                                            REPR_TYPE.TEXT_REPRESENTATION_COT,
                                                            REPR_TYPE.OPENAI_DEMOSTRATION_COT,
                                                            REPR_TYPE.ALPACA_SFT_COT,
                                                            REPR_TYPE.CBR])
    parser.add_argument("--example_type", type=str, choices=[EXAMPLE_TYPE.ONLY_SQL, 
                                                             EXAMPLE_TYPE.QA, 
                                                             EXAMPLE_TYPE.COMPLETE,
                                                             EXAMPLE_TYPE.QAWRULE,
                                                             EXAMPLE_TYPE.OPENAI_DEMOSTRATION_QA,
                                                             EXAMPLE_TYPE.BASIC_QA], default=EXAMPLE_TYPE.QA)
    parser.add_argument("--selector_type", type=str, choices=[SELECTOR_TYPE.COS_SIMILAR,
                                                              SELECTOR_TYPE.RANDOM,
                                                              SELECTOR_TYPE.EUC_DISTANCE,
                                                              SELECTOR_TYPE.EUC_DISTANCE_THRESHOLD,
                                                              SELECTOR_TYPE.EUC_DISTANCE_SKELETON_SIMILARITY_THRESHOLD,
                                                              SELECTOR_TYPE.EUC_DISTANCE_QUESTION_MASK,
                                                              SELECTOR_TYPE.EUC_DISTANCE_PRE_SKELETON_SIMILARITY_THRESHOLD,
                                                              SELECTOR_TYPE.EUC_DISTANCE_PRE_SKELETON_SIMILARITY_PLUS,
                                                              SELECTOR_TYPE.EUC_DISTANCE_MASK_PRE_SKELETON_SIMILARITY_THRESHOLD,
                                                              SELECTOR_TYPE.EUC_DISTANCE_MASK_PRE_SKELETON_SIMILARITY_THRESHOLD_SHIFT
                                                              ], default=SELECTOR_TYPE.RANDOM)
    parser.add_argument("--max_seq_len", type=int, default=2048, help="The maximal length that LLM takes")  # dummy when zero-shot
    parser.add_argument("--max_ans_len", type=int, default=200, help="The maximal length that an answer takes")
    parser.add_argument("--tokenizer", type=str, default="gpt-3.5-turbo")
    parser.add_argument("--scope_factor", type=int, default=100, help="Times of the searching scope")
    parser.add_argument("--pre_test_result", type=str, default=None)

    # for spider2
    parser.add_argument("--use_column_desc", action="store_false", default=True)
    parser.add_argument("--use_sample_rows", action="store_false", default=True)
    parser.add_argument("--use_external_knowledge", action="store_false", default=True)
    parser.add_argument("--use_few_shot", action="store_true", default=False)
    parser.add_argument("--n_shots", type=int, default=3)
    parser.add_argument("--use_special_function", action="store_true", default=False)
    parser.add_argument("--use_plan", action="store_true", default=False)

    parser.add_argument("--comment", type=str, default="")
    parser.add_argument("--processes", type=int, default=120)


    args = parser.parse_args()

    # load test dataset here
    data = Spider2CForDailSQL_Dataset(proj_dir, args)

    # Read all tables into a dict
    databases = data.get_databases()  # get self.databases of the instance "data"

    # select the prompt 
    prompt = prompt_factory(args.prompt_repr, args.k_shot, args.example_type, args.selector_type)(data=data, tokenizer=args.tokenizer)

    global questions, token_cnt, pbar
    questions = list()
    token_cnt = 0
    
    # choose split
    func_name = f"get_{args.split}_json"
    cross_domain = args.split == "train"

    question_loader = getattr(data, func_name)()

    with Pool(processes=args.processes) as pool:
        with tqdm(total=len(question_loader)) as pbar:
            for question_json in question_loader:
                pool.apply_async(
                    process_question, 
                    args=(question_json, args, cross_domain),
                    callback=collect_result
                )
            pool.close()
            pool.join() 
    
    # cost estimated
    token_cnt = float(token_cnt) / len(questions)
    print(f"Total {len(questions)} questions, {token_cnt} tokens per prompt, {token_cnt / len(questions)} tokens per question")
    
    n_total_tokens = len(questions) * args.max_ans_len + token_cnt
    cost_gpt_35_turbo = cost_estimate(n_total_tokens, LLM.GPT_35_TURBO)
    cost_text_davinci_003 = cost_estimate(n_total_tokens, LLM.TEXT_DAVINCI_003)
    example_quality = prompt.get_example_quality()
    # example_quality_each = prompt.get_example_quality_for_each()
    pattern_similarity = prompt.get_pattern_similarity()
    print(f"Example quality: {example_quality}")
    print(f"Estimated cost for {LLM.GPT_4}: {cost_gpt_35_turbo*20}")
    print(f"Estimated cost for {LLM.GPT_35_TURBO}: {cost_gpt_35_turbo}")
    print(f"Estimated cost for {LLM.TEXT_DAVINCI_003}: {cost_text_davinci_003}")

    # save questions
    task = {
        "args": vars(args),
        "costs": {
            "prompt_tokens_per_prompt": token_cnt,
            "gpt-4": cost_gpt_35_turbo*20,
            "gpt-3.5-turbo": cost_gpt_35_turbo,
            "text-davinci-003": cost_text_davinci_003,
            "example_quality": example_quality,
            "pattern_similarity": pattern_similarity,
            # "example_quality_for_each": example_quality_each
        },
        "questions": questions
    }
    # print(questions[0]['prompt'])  # for debug
    
    path_generate = f"postprocessed_data/{args.comment}_{args.dev}_CTX-{args.max_ans_len}"
    os.makedirs(path_generate, exist_ok=True)
    json.dump(task, open(os.path.join(path_generate, "questions.json"), "w"), indent=4)
    