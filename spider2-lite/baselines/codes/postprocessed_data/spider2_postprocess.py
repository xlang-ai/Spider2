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
    parser.add_argument("--comment", type=str, default='')
    args = parser.parse_args()

    root_path = osp.join(proj_dir, f'postprocessed_data/{args.comment}-{args.dev}/{args.dev}-pred-sqls')
    dev_json = osp.join(proj_dir, f'preprocessed_data/{args.dev}/{args.dev}_preprocessed.json')
    table_json = osp.join(proj_dir, 'preprocessed_data/tables_preprocessed.json')
    
    main_postprocess(root_path, dev_json, table_json, method='CODES')


