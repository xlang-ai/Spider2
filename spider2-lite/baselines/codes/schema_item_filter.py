import numpy as np
import random
import torch
import copy
from tqdm import tqdm
from transformers import AutoTokenizer
from utils.classifier_model import SchemaItemClassifier
from transformers.trainer_utils import set_seed

def prepare_inputs_and_labels(sample, tokenizer):
    table_names = [table["table_name"] for table in sample["schema"]["schema_items"]]
    column_names = [table["column_names"] for table in sample["schema"]["schema_items"]]
    column_num_in_each_table = [len(table["column_names"]) for table in sample["schema"]["schema_items"]]

    # `column_name_word_indices` and `table_name_word_indices` record the word indices of each column and table in `input_words`, whose element is an integer
    column_name_word_indices, table_name_word_indices = [], []
    
    input_words = [sample["text"]]
    for table_id, table_name in enumerate(table_names):
        input_words.append("|")
        input_words.append(table_name)
        table_name_word_indices.append(len(input_words) - 1)
        input_words.append(":")
        
        for column_name in column_names[table_id]:
            input_words.append(column_name)
            column_name_word_indices.append(len(input_words) - 1)
            input_words.append(",")
        
        # remove the last ","
        input_words = input_words[:-1]

    tokenized_inputs = tokenizer(
        input_words, 
        return_tensors="pt", 
        is_split_into_words = True,
        padding = "max_length",
        max_length = 512,
        truncation = True
    )

    # after tokenizing, one table name or column name may be splitted into multiple tokens (i.e., sub-words)
    # `column_name_token_indices` and `table_name_token_indices` records the token indices of each column and table in `input_ids`, whose element is a list of integer
    column_name_token_indices, table_name_token_indices = [], []
    word_indices = tokenized_inputs.word_ids(batch_index = 0)

    # obtain token indices of each column in `input_ids`
    for column_name_word_index in column_name_word_indices:
        column_name_token_indices.append([token_id for token_id, word_index in enumerate(word_indices) if column_name_word_index == word_index])

    # obtain token indices of each table in `input_ids`
    for table_name_word_index in table_name_word_indices:
        table_name_token_indices.append([token_id for token_id, word_index in enumerate(word_indices) if table_name_word_index == word_index])

    encoder_input_ids = tokenized_inputs["input_ids"]
    encoder_input_attention_mask = tokenized_inputs["attention_mask"]

    # print("\n".join(tokenizer.batch_decode(encoder_input_ids, skip_special_tokens = True)))

    if torch.cuda.is_available():
        encoder_input_ids = encoder_input_ids.cuda()
        encoder_input_attention_mask = encoder_input_attention_mask.cuda()

    return encoder_input_ids, encoder_input_attention_mask, \
        column_name_token_indices, table_name_token_indices, column_num_in_each_table

def get_schema(tables_and_columns):
    schema_items = []
    table_names = list(dict.fromkeys([t for t, c in tables_and_columns]))
    for table_name in table_names:
        schema_items.append(
            {
                "table_name": table_name,
                "column_names":  [c for t, c in tables_and_columns if t == table_name]
            }
        )
    
    return {"schema_items": schema_items}

def get_sequence_length(text, tables_and_columns, tokenizer):
    table_names = [t for t, c in tables_and_columns]
    # duplicate `table_names` while preserving order
    table_names = list(dict.fromkeys(table_names))
    
    column_names = []
    for table_name in table_names:
        column_names.append([c for t, c in tables_and_columns if t == table_name])
    
    input_words = [text]
    for table_id, table_name in enumerate(table_names):
        input_words.append("|")
        input_words.append(table_name)
        input_words.append(":")
        for column_name in column_names[table_id]:
            input_words.append(column_name)
            input_words.append(",")
        # remove the last ","
        input_words = input_words[:-1]

    tokenized_inputs = tokenizer(
        input_words, 
        is_split_into_words=True,
        max_length=512, 
        truncation=True
    )

    return len(tokenized_inputs["input_ids"])

# handle extremely long schema sequences
def split_sample(sample, tokenizer):
    text = sample["text"]

    table_names = []
    column_names = []
    for table in sample["schema"]["schema_items"]:
        table_names.append(table["table_name"] + " ( " + table["table_comment"] + " ) " \
            if table["table_comment"] != "" else table["table_name"])
        column_names.append([column_name + " ( " + column_comment + " ) " \
            if column_comment != "" else column_name \
                for column_name, column_comment in zip(table["column_names"], table["column_comments"])])

    splitted_samples = []
    recorded_tables_and_columns = []

    for table_idx, table_name in enumerate(table_names):
        for column_name in column_names[table_idx]:
            if get_sequence_length(text, recorded_tables_and_columns + [[table_name, column_name]], tokenizer) < 500:
                recorded_tables_and_columns.append([table_name, column_name])
            else:
                splitted_samples.append(
                    {
                        "text": text,
                        "schema": get_schema(recorded_tables_and_columns)
                    }
                )
                recorded_tables_and_columns = [[table_name, column_name]]
    
    splitted_samples.append(
        {
            "text": text,
            "schema": get_schema(recorded_tables_and_columns)
        }
    )

    return splitted_samples

def merge_pred_results(sample, pred_results):
    # table_names = [table["table_name"] for table in sample["schema"]["schema_items"]]
    # column_names = [table["column_names"] for table in sample["schema"]["schema_items"]]
    table_names = []
    column_names = []
    for table in sample["schema"]["schema_items"]:
        table_names.append(table["table_name"] + " ( " + table["table_comment"] + " ) " \
            if table["table_comment"] != "" else table["table_name"])
        column_names.append([column_name + " ( " + column_comment + " ) " \
            if column_comment != "" else column_name \
                for column_name, column_comment in zip(table["column_names"], table["column_comments"])])

    merged_results = []
    for table_id, table_name in enumerate(table_names):
        table_prob = 0
        column_probs = []
        for result_dict in pred_results:
            if table_name in result_dict:
                if table_prob < result_dict[table_name]["table_prob"]:
                    table_prob = result_dict[table_name]["table_prob"]
                column_probs += result_dict[table_name]["column_probs"]

        merged_results.append(
            {
                "table_name": table_name,
                "table_prob": table_prob,
                "column_names": column_names[table_id],
                "column_probs": column_probs
            }
        )
    
    return merged_results

def filter_schema(dataset, dataset_type, sic, num_top_k_tables = 5, num_top_k_columns = 5):

    for data in tqdm(dataset, desc = "filtering schema items for the dataset"):
        filtered_schema = dict()
        filtered_matched_contents = dict()
        filtered_schema["schema_items"] = []
        filtered_schema["foreign_keys"] = []

        table_names = [table["table_name"] for table in data["schema"]["schema_items"]]
        table_comments = [table["table_comment"] for table in data["schema"]["schema_items"]]
        column_names = [table["column_names"] for table in data["schema"]["schema_items"]]
        column_types = [table["column_types"] for table in data["schema"]["schema_items"]]
        column_comments = [table["column_comments"] for table in data["schema"]["schema_items"]]
        column_contents = [table["column_contents"] for table in data["schema"]["schema_items"]]
        pk_indicators = [table["pk_indicators"] for table in data["schema"]["schema_items"]]

        if dataset_type == "eval":
            # predict scores for each tables and columns
            pred_results = sic.predict(data)  # >>>pred_results[0] {'table_name': 'stadium', 'table_prob': 0.09157884865999222, 'column_names': ['stadium_id', 'location', 'name', 'capacity', 'highest', 'lowest', 'average'], 'column_probs': [0.011393537744879723, 0.043684110045433044, 0.04848432168364525, 0.04443831369280815, 0.045400623232126236, 0.04387670382857323, 0.043790124356746674]}
            # remain top_k1 tables for each database and top_k2 columns for each remained table
            table_probs = [pred_result["table_prob"] for pred_result in pred_results]
            table_indices = np.argsort(-np.array(table_probs), kind="stable")[:num_top_k_tables].tolist()
        elif dataset_type == "train":
            raise NotImplementedError("For spider2.0, filtering schema items for training dataset is not implemented yet!")

        for table_idx in table_indices:
            if dataset_type == "eval":
                column_probs = pred_results[table_idx]["column_probs"]
                column_indices = np.argsort(-np.array(column_probs), kind="stable")[:num_top_k_columns].tolist()
            elif dataset_type == "train":
                column_indices = [column_idx for column_idx, column_label in enumerate(data["column_labels"][table_idx]) if column_label == 1]
                if len(column_indices) < num_top_k_columns:
                    unused_column_indices = [column_idx for column_idx, column_label in enumerate(data["column_labels"][table_idx]) if column_label == 0]
                    column_indices += random.sample(unused_column_indices, min(len(unused_column_indices), num_top_k_columns - len(column_indices)))
                random.shuffle(column_indices)

            try:
                filtered_schema["schema_items"].append(
                    {
                        "table_name": table_names[table_idx],
                        "table_comment": table_comments[table_idx],
                        "column_names": [column_names[table_idx][column_idx] for column_idx in column_indices],
                        "column_types": [column_types[table_idx][column_idx] for column_idx in column_indices],
                        "column_comments": [column_comments[table_idx][column_idx] for column_idx in column_indices],
                        "column_contents": [column_contents[table_idx][column_idx] for column_idx in column_indices],
                        "pk_indicators": [pk_indicators[table_idx][column_idx] for column_idx in column_indices]
                    }
                )
            except:
                print(f"warning: for instance {data['instance_id']} column_names length is invalid!")
                column_indices = np.random.choice(
                    len(column_names[table_idx]), 
                    min(len(column_names[table_idx]), num_top_k_columns), 
                    replace=False
                )
                
                filtered_schema["schema_items"].append(
                    {
                        "table_name": table_names[table_idx],
                        "table_comment": table_comments[table_idx],
                        "column_names": [column_names[table_idx][column_idx] for column_idx in column_indices],
                        "column_types": [column_types[table_idx][column_idx] for column_idx in column_indices],
                        "column_comments": [column_comments[table_idx][column_idx] for column_idx in column_indices],
                        "column_contents": [column_contents[table_idx][column_idx] for column_idx in column_indices],
                        "pk_indicators": [pk_indicators[table_idx][column_idx] for column_idx in column_indices]
                    }
                )

        
            for column_name in [column_names[table_idx][column_idx] for column_idx in column_indices]:
                tc_name = "{}.{}".format(table_names[table_idx], column_name)  # tc_name = 'singer.singer_id'
                if tc_name in data["matched_contents"]:
                    filtered_matched_contents[tc_name] = data["matched_contents"][tc_name]
        
        # extract foreign keys among remianed tables
        filtered_table_names = [table_names[table_idx] for table_idx in table_indices]
        for foreign_key in data["schema"]["foreign_keys"]:
            source_table, source_column, target_table, target_column = foreign_key
            if source_table in filtered_table_names and target_table in filtered_table_names:
                filtered_schema["foreign_keys"].append(foreign_key)

        # replace the old schema with the filtered schema
        data["schema"] = filtered_schema
        # replace the old matched contents with the filtered matched contents
        data["matched_contents"] = filtered_matched_contents

    return dataset

def lista_contains_listb(lista, listb):
    for b in listb:
        if b not in lista:
            return 0
    
    return 1

class SchemaItemClassifierInference():
    def __init__(self, model_save_path):
        set_seed(42)
        # load tokenizer
        self.tokenizer = AutoTokenizer.from_pretrained(model_save_path, add_prefix_space = True)
        # initialize model
        self.model = SchemaItemClassifier(model_save_path, "test")
        # load fine-tuned params
        self.model.load_state_dict(torch.load(model_save_path + "/dense_classifier.pt", map_location=torch.device('cpu')), strict=False)
        if torch.cuda.is_available():
            self.model = self.model.cuda()
        self.model.eval()
    
    def predict_one(self, sample):
        encoder_input_ids, encoder_input_attention_mask, column_name_token_indices,\
            table_name_token_indices, column_num_in_each_table = prepare_inputs_and_labels(sample, self.tokenizer)

        with torch.no_grad():
            model_outputs = self.model(
                encoder_input_ids,
                encoder_input_attention_mask,
                [column_name_token_indices],
                [table_name_token_indices],
                [column_num_in_each_table]
            )

        table_logits = model_outputs["batch_table_name_cls_logits"][0]
        table_pred_probs = torch.nn.functional.softmax(table_logits, dim = 1)[:, 1].cpu().tolist()
            
        column_logits = model_outputs["batch_column_info_cls_logits"][0]
        column_pred_probs = torch.nn.functional.softmax(column_logits, dim = 1)[:, 1].cpu().tolist()

        splitted_column_pred_probs = []
        # split predicted column probs into each table
        for table_id, column_num in enumerate(column_num_in_each_table):
            splitted_column_pred_probs.append(column_pred_probs[sum(column_num_in_each_table[:table_id]): sum(column_num_in_each_table[:table_id]) + column_num])
        column_pred_probs = splitted_column_pred_probs

        result_dict = dict()
        for table_idx, table in enumerate(sample["schema"]["schema_items"]):
            result_dict[table["table_name"]] = {
                "table_name": table["table_name"],
                "table_prob": table_pred_probs[table_idx],
                "column_names": table["column_names"],
                "column_probs": column_pred_probs[table_idx],
            }

        return result_dict

    def predict(self, test_sample):
        splitted_samples = split_sample(test_sample, self.tokenizer)
        pred_results = []
        for splitted_sample in splitted_samples:
            pred_results.append(self.predict_one(splitted_sample))
        
        return merge_pred_results(test_sample, pred_results)
    
    def evaluate_coverage(self, dataset):
        max_k = 100
        total_num_for_table_coverage, total_num_for_column_coverage = 0, 0
        table_coverage_results = [0]*max_k
        column_coverage_results = [0]*max_k

        for data in dataset:
            indices_of_used_tables = [idx for idx, label in enumerate(data["table_labels"]) if label == 1]
            pred_results = sic.predict(data)
            # print(pred_results)
            table_probs = [res["table_prob"] for res in pred_results]
            for k in range(max_k):
                indices_of_top_k_tables = np.argsort(-np.array(table_probs), kind="stable")[:k+1].tolist()
                if lista_contains_listb(indices_of_top_k_tables, indices_of_used_tables):
                    table_coverage_results[k] += 1
            total_num_for_table_coverage += 1

            for table_idx in range(len(data["table_labels"])):
                indices_of_used_columns = [idx for idx, label in enumerate(data["column_labels"][table_idx]) if label == 1]
                if len(indices_of_used_columns) == 0:
                    continue
                column_probs = pred_results[table_idx]["column_probs"]
                for k in range(max_k):
                    indices_of_top_k_columns = np.argsort(-np.array(column_probs), kind="stable")[:k+1].tolist()
                    if lista_contains_listb(indices_of_top_k_columns, indices_of_used_columns):
                        column_coverage_results[k] += 1

                total_num_for_column_coverage += 1

                indices_of_top_10_columns = np.argsort(-np.array(column_probs), kind="stable")[:10].tolist()
                if lista_contains_listb(indices_of_top_10_columns, indices_of_used_columns) == 0:
                    print(pred_results[table_idx])
                    print(data["column_labels"][table_idx])
                    print(data["question"])

        print(total_num_for_table_coverage)
        print(table_coverage_results)
        print(total_num_for_column_coverage)
        print(column_coverage_results)
    
if __name__ == "__main__":
    dataset_name = "bird_with_evidence"
    # dataset_name = "bird"
    # dataset_name = "spider"
    sic = SchemaItemClassifierInference("sic_ckpts/sic_{}".format(dataset_name))
    import json
    dataset = json.load(open("./data/sft_eval_{}_text2sql.json".format(dataset_name)))
    
    sic.evaluate_coverage(dataset)