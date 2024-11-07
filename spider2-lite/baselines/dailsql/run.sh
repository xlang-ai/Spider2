#!/bin/bash

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# DEV=spider2-lite_0930
DEV=toy
LLM=gpt-4o
COMMENT=1025

# step1. preprocess
cd ${script_dir}  
python preprocessed_data/spider2_preprocess.py --dev $DEV

# step2. run DAIL-SQL
python data_preprocess.py --dev $DEV 
python generate_question.py --dev $DEV --model $LLM --tokenizer $LLM --prompt_repr SQL --k_shot 0 --comment $COMMENT
python ask_llm.py --openai_api_key $OPENAI_API_KEY --model $LLM --n 1 --question postprocessed_data/${COMMENT}_${DEV}_CTX-200 

# step3. postprocess
python postprocessed_data/spider2_postprocess.py --dev $DEV --model $LLM --comment $COMMENT

# step4. evaluate
eval_suite_dir=$(readlink -f "${script_dir}/../../evaluation_suite")
cd ${eval_suite_dir}
python evaluate_yx.py --mode sql --dev $DEV --result_dir ${script_dir}/postprocessed_data/${COMMENT}_${DEV}_CTX-200/RESULTS_MODEL-${LLM}-SQL-postprocessed 