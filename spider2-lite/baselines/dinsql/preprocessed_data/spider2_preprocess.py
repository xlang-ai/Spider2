# import debugpy; debugpy.connect(("127.0.0.1", 5688))
import numpy as np
import json
import os
import os.path as osp
import requests
import argparse
from datetime import date
import sys
import glob
import matplotlib.pyplot as plt
import re

proj_dir = osp.dirname(osp.dirname(osp.abspath(__file__)))
sys.path = [osp.join(proj_dir, '../')] + sys.path

from utils.utils import walk_metadata, get_special_function_summary
# borrow the preprocess code from dailsql
from dailsql.preprocessed_data.spider2_preprocess import process_table_json, process_dev_json



if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    parser.add_argument('--dev', default='spider2_dev', type=str, help='the name of dev file')
    args = parser.parse_args()

    process_table_json(args, proj_dir)
    process_dev_json(args, proj_dir)


