#!/bin/bash

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DEV=spider2-lite
LLM=gpt-4o

# step1. preprocess
cd ${script_dir}  
python preprocessed_data/spider2_preprocess.py --dev $DEV

# step2. run DAIL-SQL
python data_preprocess.py --dev $DEV 
python generate_question.py --dev $DEV --model $LLM --tokenizer $LLM --prompt_repr SQL --k_shot 0
python ask_llm.py --openai_api_key $OPENAI_API_KEY --model $LLM --n 1 --question postprocessed_data/${DEV}_CTX-200 | tee ${script_dir}/postprocessed_data/${DEV}_CTX-200/ask_llm.log

# step3. postprocess
python postprocessed_data/spider2_postprocess.py --dev $DEV --model $LLM

# step4. evaluate
eval_suite_dir=$(readlink -f "${script_dir}/../../evaluation_suite")
cd ${eval_suite_dir}
python evaluate.py --mode sql --result_dir ${script_dir}/postprocessed_data/${DEV}_CTX-200/RESULTS_MODEL-${LLM}-SQL-postprocessed | tee ${script_dir}/postprocessed_data/${DEV}_CTX-200/evaluate.log


