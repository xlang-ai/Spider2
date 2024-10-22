from utils.utils import get_tokenizer, count_tokens, jaccard_similarity
import numpy as np
import json

class BasicICLPrompt(object):
    NUM_EXAMPLE = None
    SEP_EXAMPLE = "\n\n"

    def __init__(self, tokenizer: str, *args, **kwargs):
        self.tokenizer = get_tokenizer(tokenizer)
        self.example_qualities = []
        self.pattern_similarities = []

    def record_example_quality(self, examples, target):
        quality_list = []
        for example in examples:
            quality_list.append(jaccard_similarity(example["query_skeleton"], target["query_skeleton"]))
        self.example_qualities.append(quality_list)

    def get_example_quality(self):
        if self.example_qualities:
            return np.mean([num for row in self.example_qualities for num in row])
        else:
            return 1

    def get_example_quality_for_each(self):
        if self.example_qualities:
            return [np.mean(row) for row in self.example_qualities]
        else:
            return []

    def record_pattern_similarity(self, examples, target):
        similarity_list = []
        for example in examples:
            similarity_list.append(jaccard_similarity(example["question_pattern"], target["question_pattern"]))
        self.pattern_similarities.append(similarity_list)

    def get_pattern_similarity(self):
        if self.pattern_similarities:
            return np.mean([num for row in self.pattern_similarities for num in row])
        else:
            return 1

    def format(self, target: dict, max_seq_len: int, max_ans_len: int, scope_factor: int, cross_domain=False, args=None):  
        # target question
        prompt_target = self.format_target(target, args)
        sum_tokens = count_tokens(prompt_target, tokenizer=self.tokenizer)
        
        if self.NUM_EXAMPLE != 0:
            # example questions
            examples = self.get_examples(target, self.NUM_EXAMPLE * scope_factor, cross_domain=cross_domain)
            prompt_example = list()
            question = target["question"]
            example_prefix = self.get_example_prefix()
            selected_examples = []
            for example in examples:
                example_question = example["question"]
                # assert example_question != question, f"Example is the same with target question: {question}!, \n{target}\n{example}"
                if cross_domain:
                    assert target["db_id"] != example["db_id"]

                example_format = self.format_example(example)
                
                # count tokens and drop the example if exceed max_len
                forward_tokens = count_tokens(example_prefix + self.SEP_EXAMPLE.join(prompt_example + [example_format, prompt_target]), tokenizer=self.tokenizer)
                
                if forward_tokens + max_ans_len <= max_seq_len:
                    # add an example
                    prompt_example.append(example_format)
                    # update tokens
                    sum_tokens = forward_tokens
                    # record the selected examples
                    selected_examples.append(example)
                    
                    if len(prompt_example) >= self.NUM_EXAMPLE:
                        break

            self.record_example_quality(selected_examples, target)
            self.record_pattern_similarity(selected_examples, target)
            
            n_valid_example = len(prompt_example)
            if len(prompt_example) > 0:
                prompt = example_prefix + self.SEP_EXAMPLE.join(prompt_example + [prompt_target])
            else:
                prompt = self.SEP_EXAMPLE.join(prompt_example + [prompt_target])
        else:
            n_valid_example = 0
            prompt = prompt_target
        
        response_clean = " ".join(target["query"].split())[len("SELECT "):]
        return {
            "prompt_tokens": sum_tokens,
            "prompt": prompt,
            "response": response_clean, 
            "n_examples": n_valid_example,
            "db_id": target["db_id"]
        }