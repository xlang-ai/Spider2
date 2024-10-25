import json
from scipy import special
import torch
import gc
import os.path as osp
from datasets import Dataset
from torch.utils.data import Dataset
from schema_item_filter import SchemaItemClassifierInference, filter_schema
from utils.db_utils import get_db_schema_sequence, get_matched_content_sequence

proj_dir = osp.dirname(osp.dirname(osp.abspath(__file__)))

def prepare_text2sql_prefix_sequence(data, args):

    # DECRECATED, hard trunc outside
    # def check_length(current_prompt, new):
    #     return len(current_prompt) + len(data["text"]) + len(new) < 1048570

    if args.use_few_shot:
        with open(osp.join(proj_dir, '../utils/3-shot-for-codes.txt'), 'r', encoding='utf-8') as file:
            content = file.read()
        demo = content + "\n\n"
    else:
        demo = ''

    if args.use_external_knowledge and data['external_knowledge'] is not None:
        with open(osp.join(proj_dir, '../../resource/documentation/external_knowledge', data['external_knowledge']), "r", encoding="utf-8") as file:
            content = file.read()
        knowledge = 'external knowledge:' + content + "\n"
    else: 
        knowledge = ''

    if args.use_special_function and data["special_function"] is not None:
        strs = [f"{item['name']}: {item['summary']}" for item in data['special_function']]
        special_function = "\n".join(strs)
        special_function = 'potentially useful special functions with their usage:' + special_function + "\n"
    else:
        special_function = ''

    if args.use_plan and data["plan"] is not None:
        plan = 'a plan that is useful for guiding the generation of components of a complete SQL query:' + data["plan"] + "\n"
    else:
        plan = ''
        
    # caution: reverse trunc outside
    prefix_seq = \
        special_function + \
        plan + \
        demo + \
        knowledge + \
        data["content_sequence"] + "\n" + \
        data["schema_sequence"] + "\n" + \
        data["text"] + "\n"
    
    return prefix_seq  

def prepare_inputs_and_labels(prefix_seq, target_seq, tokenizer, max_tokens):
    prefix_ids = [tokenizer.bos_token_id] + tokenizer(prefix_seq , truncation = False)["input_ids"]
    target_ids = tokenizer(target_seq, truncation = False)["input_ids"] + [tokenizer.eos_token_id]

    seq_length = len(prefix_ids) + len(target_ids)
    if seq_length <= max_tokens: # pad inputs with pad_token_id
        pad_length = max_tokens - seq_length
        input_ids = prefix_ids + target_ids + [tokenizer.pad_token_id] * pad_length
        # tell the model to ignore the padding tokens when performing (masked) self-attention 
        attention_mask = [1] * seq_length + [0] * pad_length
        # only target_ids produces gradients
        labels = [-100] * len(prefix_ids) + target_ids + [-100] * pad_length
    else: # no padding
        print("the current input sequence exceeds the max_tokens, we will truncate it.")
        input_ids = prefix_ids + target_ids
        # pre-truncate input ids
        input_ids = [tokenizer.bos_token_id] + input_ids[-(max_tokens-1):]
        attention_mask = [1] * max_tokens
        # only target_ids produces gradients
        labels = [-100] * len(prefix_ids) + target_ids
        # pre-truncate labels
        labels = labels[-max_tokens:]
    
    return {
        "input_ids": torch.tensor(input_ids, dtype = torch.int64), 
        "attention_mask": torch.tensor(attention_mask, dtype = torch.int64), 
        "labels": torch.tensor(labels, dtype = torch.int64)
    }

def prepare_inputs(prefix_seq, tokenizer, max_prefix_length):
    input_ids = [tokenizer.bos_token_id] + tokenizer(prefix_seq , truncation = False)["input_ids"]

    if len(input_ids) > max_prefix_length:
        print("\n\n--------------\n>>>the current input sequence exceeds the max_tokens, we will truncate it!!!\n--------------\n\n")
        input_ids = [tokenizer.bos_token_id] + input_ids[-(max_prefix_length-1):]
    
    attention_mask = [1] * len(input_ids)
    
    return {
        "input_ids": torch.tensor(input_ids, dtype = torch.int64),
        "attention_mask": torch.tensor(attention_mask, dtype = torch.int64)
    }

class SFTSQLGenerationDataset(Dataset):
    def __init__(self, text2sql_data_dir, tokenizer, max_tokens, mode, table_num, column_num, sic_path, args):
        super().__init__()
        dataset = json.load(open(text2sql_data_dir))

        print("apply filtering strategies...")
        if mode == "train":
            dataset = filter_schema(dataset, "train", None, table_num, column_num)
        elif mode == "eval":
            sic = SchemaItemClassifierInference(sic_path)
            # filtering schema items for the dataset
            dataset = filter_schema(dataset, "eval", sic, table_num, column_num)  
            del sic
            torch.cuda.empty_cache()

        # prepare schema sequence and content sequence
        for data in dataset:
            data["schema_sequence"] = get_db_schema_sequence(data["schema"])
            data["content_sequence"] = get_matched_content_sequence(data["matched_contents"])  # matched contents

        
        self.mode = mode
        self.dataset = dataset
        self.tokenizer = tokenizer
        self.max_tokens = max_tokens
        self.args = args

    def __getitem__(self, index):
        data = self.dataset[index]
        prefix_seq = prepare_text2sql_prefix_sequence(data, self.args)  
        # if index < 2:
        #    print(prefix_seq)

        if self.mode == "train":
            target_seq = data["sql"]
            return prepare_inputs_and_labels(prefix_seq, target_seq, self.tokenizer, self.max_tokens)
        elif self.mode == "eval":
            return prepare_inputs(prefix_seq, self.tokenizer, self.max_tokens)  
            # return prepare_inputs(prefix_seq, self.tokenizer, self.max_tokens), prefix_seq

    def __len__(self):
        return len(self.dataset)