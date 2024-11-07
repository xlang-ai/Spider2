#!/bin/bash
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# DEV=spide2-lite
DEV=toy
LLM=gpt-4o-2024-08-06
COMMENT=1107

# step1. preprocess
cd ${script_dir}  
python preprocessed_data/spider2_preprocess.py --dev $DEV
python DIN-SQL.py --dev $DEV --n 1 --temperature 0.0 --processes 1

python postprocessed_data/spider2_postprocess.py --dev $DEV 

eval_suite_dir=$(readlink -f "${script_dir}/../../evaluation_suite")
cd ${eval_suite_dir}
python evaluate_yx.py --mode sql --result_dir ${script_dir}/postprocessed_data/${DEV}/predicted-SQL-postprocessed
