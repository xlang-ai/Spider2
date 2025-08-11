# import debugpy; debugpy.connect(('127.0.0.1', 5688))
import os
import json
import re
import os.path as osp
import argparse
import sys

proj_dir = osp.dirname(osp.dirname(osp.abspath(__file__)))
sys.path = [osp.join(proj_dir, '../')] + sys.path
from utils.post_utils import main_postprocess


if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument('--dev', default='spider2_dev', type=str, help='the name of dev file')
    parser.add_argument('--model', default='gpt-3.5-turbo', type=str)
    parser.add_argument('--comment', default='', type=str)
    parser.add_argument('--max_tokens', type=int, default=200)
    parser.add_argument("--is_sql_debug", action="store_true", default=False)
    args = parser.parse_args()

    DEBUG_PREFIX = "SQL_DEBUG_" if args.is_sql_debug else ""
    root_path = osp.join(proj_dir, f'postprocessed_data/{args.comment}_{args.dev}_CTX-{args.max_tokens}/{DEBUG_PREFIX}RESULTS_MODEL-{args.model}-SQL')
    dev_json = osp.join(proj_dir, f'preprocessed_data/{args.dev}/{args.dev}_preprocessed.json')
    table_json = osp.join(proj_dir, f'preprocessed_data/{args.dev}/tables_preprocessed.json')

    main_postprocess(root_path, dev_json, table_json, method='DAIL-SQL')


