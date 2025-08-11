import json
import itertools
from torch.utils.data import Dataset

class SchemaItemClassifierDataset(Dataset):
    def __init__(self, dataset_dir):
        super(SchemaItemClassifierDataset, self).__init__()

        self.texts: list[str] = []
        self.all_column_names: list[list[list[str]]] = []
        self.all_column_labels: list[list[list[int]]] = []
        self.all_table_names: list[list[str]] = []
        self.all_table_labels: list[list[int]] = []
        
        dataset = json.load(open(dataset_dir))
        
        assert type(dataset) == list
        
        for data in dataset:
            table_names_in_one_db = []
            column_names_in_one_db = []

            for table in data["schema"]["schema_items"]:
                # table_names_in_one_db.append(table["table_name"])
                # column_names_in_one_db.append(table["column_names"])
                table_names_in_one_db.append(table["table_name"] + " ( " + table["table_comment"] + " ) " \
                    if table["table_comment"] != "" else table["table_name"])
                column_names_in_one_db.append([column_name + " ( " + column_comment + " ) " \
                    if column_comment != "" else column_name \
                        for column_name, column_comment in zip(table["column_names"], table["column_comments"])])

            self.texts.append(data["text"])
            self.all_table_names.append(table_names_in_one_db)
            self.all_column_names.append(column_names_in_one_db)
            self.all_table_labels.append(data["table_labels"])
            self.all_column_labels.append(list(itertools.chain(*data["column_labels"])))
    
    def __len__(self):
        return len(self.texts)
    
    def __getitem__(self, index):
        text = self.texts[index]
        table_names_in_one_db = self.all_table_names[index]
        table_labels_in_one_db = self.all_table_labels[index]
        column_infos_in_one_db = self.all_column_names[index]
        column_labels_in_one_db = self.all_column_labels[index]

        return {
            "text": text,
            "table_names_in_one_db": table_names_in_one_db,
            "table_labels_in_one_db": table_labels_in_one_db,
            "column_infos_in_one_db": column_infos_in_one_db,
            "column_labels_in_one_db": column_labels_in_one_db
        }
