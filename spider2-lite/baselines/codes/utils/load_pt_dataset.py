# saves the SQL corpus to several binary files for pre-training CodeGen. following was helpful:
# https://github.com/karpathy/nanoGPT/blob/master/data/openwebtext/prepare.py

import numpy as np
import torch
import random
from torch.utils.data import IterableDataset, Dataset, DataLoader

# class PretrainDataset(IterableDataset):
#     def __init__(self, pt_data_dir, block_size, epochs):
#         super().__init__()
#         self.corpus = np.memmap(pt_data_dir, dtype = np.uint16, mode = 'r')
#         self.block_size = block_size
#         self.epochs = epochs
#         self.length = len(self.corpus) // self.block_size

#     # return a tokenized sequence
#     def __iter__(self):
#         for _ in range(self.epochs):
#             start_idx_list = list(range(0, len(self.corpus), self.block_size))
#             # for each epoch, shuffle the order of sequences
#             random.shuffle(start_idx_list)

#             for start_idx in start_idx_list:
#                 input_ids = self.corpus[start_idx: start_idx + self.block_size]
#                 # skip the sequence whose length is not equal to `block_size`
#                 if len(input_ids) != self.block_size:
#                     continue

#                 input_ids = torch.from_numpy(input_ids.astype(np.int64))
#                 attention_mask = torch.ones(len(input_ids))

#                 yield {"input_ids": input_ids, "attention_mask": attention_mask, "labels": input_ids}

#     # # return a tokenized sequence
#     # def __iter__(self):
#     #     for _ in range(self.dataset_length):
#     #         # randomly select a sequence of token ids from the tokenized corpus
#     #         idx = random.randint(0, len(self.corpus) - self.block_size)
#     #         input_ids = self.corpus[idx: idx + self.block_size]
#     #         input_ids = torch.from_numpy(input_ids.astype(np.int64))
#     #         attention_mask = torch.ones(len(input_ids))

#     #         yield {"input_ids": input_ids, "attention_mask": attention_mask, "labels": input_ids}

#     def __len__(self):
#         return self.length

class PretrainDataset(Dataset):
    def __init__(self, pt_data_dir, block_size):
        super().__init__()
        self.corpus = np.memmap(pt_data_dir, dtype = np.uint16, mode = 'r')
        self.block_size = block_size
        self.length = len(self.corpus) // self.block_size

    # return a list of token ids in the corpus
    def __getitem__(self, index):
        input_ids = self.corpus[index * self.block_size : (index + 1) * self.block_size]

        input_ids = torch.from_numpy(input_ids.astype(np.int64))
        attention_mask = torch.ones(len(input_ids))

        return {"input_ids": input_ids, "attention_mask": attention_mask, "labels": input_ids}

    def __len__(self):
        return self.length

if __name__ == "__main__":
    dataset = PretrainDataset("./data/pt_corpus/starcoder_corpus.bin", 6144)
    dataloader = DataLoader(dataset, batch_size = 4, shuffle = False, drop_last = True)
    for batch in dataloader:
        print("-"*20)
    print(len(dataset))