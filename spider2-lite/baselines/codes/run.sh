#!/bin/bash
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DEV=spider2-lite
LLM=/data1/llms/codes-7b-merged

# step1. preprocess
cd ${script_dir}  
python preprocessed_data/spider2_preprocess.py --dev $DEV

# step2. run CodeS  
python -u text2sql_zero_shot.py \
    --llm_path $LLM --sic_path ./sic_ckpts/sic_bird \
    --table_num 6 --column_num 10 --max_tokens 8000 --max_new_tokens 1000 \
    --dev $DEV --dataset_path preprocessed_data/${DEV}/sft_${DEV}_preprocessed.json \

# step3. postprocess
python postprocessed_data/spider2_postprocess.py --dev $DEV

# step4. evaluate
eval_suite_dir=$(readlink -f "${script_dir}/../../evaluation_suite")
cd ${eval_suite_dir}
python evaluate.py --mode sql --result_dir ${script_dir}/postprocessed_data/${DEV}/${DEV}-pred-sqls-postprocessed


