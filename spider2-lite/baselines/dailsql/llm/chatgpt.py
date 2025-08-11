import json.decoder

import openai
from utils.enums import LLM
import time
import os

# os.environ["http_proxy"]="http://127.0.0.1:61081"
# os.environ["https_proxy"]="http://127.0.0.1:61081"


def init_chatgpt(OPENAI_API_KEY, OPENAI_GROUP_ID, model):
    # if model == LLM.TONG_YI_QIAN_WEN:
    #     import dashscope
    #     dashscope.api_key = OPENAI_API_KEY
    # else:
    #     openai.api_key = OPENAI_API_KEY
    #     openai.organization = OPENAI_GROUP_ID
    openai.api_key = OPENAI_API_KEY
    openai.organization = OPENAI_GROUP_ID


# def ask_completion(model, batch, temperature, max_tokens):
#     response = openai.Completion.create(
#         model=model,
#         prompt=batch,
#         temperature=temperature,
#         max_tokens=max_tokens,
#         top_p=1,
#         frequency_penalty=0,
#         presence_penalty=0,
#         stop=[";"]
#     )
#     response_clean = [_["text"] for _ in response["choices"]]
#     return dict(
#         response=response_clean,
#         **response["usage"]
#     )


def ask_chat(model, messages: list, temperature, n, max_tokens):
    print('>>>model:', model)
    print('>>>max_tokens:', max_tokens)
    if model == LLM.GPT_o1:
        response = openai.ChatCompletion.create(
            model=model,
            messages=messages,
            # temperature=temperature,
            # max_completion_tokens=max_tokens,  # will cause output dummy string
            n=n
        )
    else:
        response = openai.ChatCompletion.create(
            model=model,
            messages=messages,
            temperature=temperature,
            max_tokens=max_tokens,
            n=n
        )
    response_clean = [choice["message"]["content"] for choice in response["choices"]]
    return dict(
        response=response_clean,
        **response["usage"]
    )


# def ask_llm(model: str, batch: list, temperature: float, n:int, max_tokens):
#     n_repeat = 0
#     response = {"total_tokens": 0, "response": [["SELECT" for _ in range(n)]]}
#     while n_repeat < 1:
#         try:
#             assert model in LLM.TASK_CHAT, "LLM.TASK_COMPLETIONS is too old. not supported."
#             # batch size must be 1
#             assert len(batch) == 1, "batch must be 1 in this mode"
#             messages = [{"role": "user", "content": batch[0]}]
#             response = ask_chat(model, messages, temperature, n, max_tokens)
#             response['response'] = [response['response']]  # hard-code for batch_size=1
#             break
#         except openai.error.RateLimitError:
#             n_repeat += 1
#             print(f"Repeat for the {n_repeat} times for RateLimitError", end="\n")
#             time.sleep(1)
#             continue
#         except json.decoder.JSONDecodeError:
#             n_repeat += 1
#             print(f"Repeat for the {n_repeat} times for JSONDecodeError", end="\n")
#             time.sleep(1)
#             continue
#         except Exception as e:
#             n_repeat += 1
#             print(f"Repeat for the {n_repeat} times for exception: {e}", end="\n")
#             time.sleep(1)
#             continue
        
#     return response


def ask_llm(model: str, batch: list, temperature: float, n:int, max_tokens):
    try:
        assert model in LLM.TASK_CHAT, "LLM.TASK_COMPLETIONS is too old. not supported."
        # batch size must be 1
        assert len(batch) == 1, "batch must be 1 in this mode"
        messages = [{"role": "user", "content": batch[0]}]
        response = ask_chat(model, messages, temperature, n, max_tokens)
        response['response'] = [response['response']]  # hard-code for batch_size=1
    except (openai.error.RateLimitError, json.decoder.JSONDecodeError, Exception) as e:
        print(f"Error occurred: {e}")
        # Return hard-coded response
        response = {"total_tokens": 0, "response": [["SELECT" for _ in range(n)]]}
    
    return response

