from utils.utils import get_sql_for_database, get_sql_for_database_from_tables_json, get_sample_rows_for_database_from_tables_json
import json
import os
import os.path as osp
import tiktoken


proj_dir = osp.dirname(osp.dirname(osp.abspath(__file__)))


class BasicPrompt(object):
    def __init__(self, *args, **kwargs):
        # used to avoid empty init function in 0-shot prompt
        pass

    def format_target(self, example: dict, args):
        # return self.format_question(example, args) + "\nSELECT "
        # crucial: In spider2, not every SQL startswith "SELECT". they might startswith "WITH".
        return self.format_question(example, args) + "\n"

    def format_question(self, example: dict):
        raise NotImplementedError()

    def get_extra_info(self, db_id):
        return None


class SQLPrompt(BasicPrompt):


    template_info =   "/* Given the following database schema: */\n" \
                      "{}"
    sample_rows_info = "/* Sample rows from the tables: */\n" \
                      "{}"
    external_knowledge_info = "/* External knowledge: */\n" \
                      "{}"
    special_function_info = "/* Potentially useful special functions with their usage: */\n" \
                      "{}"
    plan_info = "/* A plan that is useful for guiding the generation of components of a complete SQL query: */\n" \
                      "{}"
    
    # specify different SQL dialect (bq, sqlite, snowflake) here.
    template_question = "/* Answer the following with a {} SQL statement without any explanation and don't use ```sql```: {} */"
    template_question_optimized = "/* Generate a {} SQL statement to answer the following question, ensuring that the syntax and functions are appropriate for {}. No explanation is required and don't use ```sql```: {} */"
        
    def format_question(self, example: dict, args):
        tables_json = json.load(open(osp.join(proj_dir, f'preprocessed_data/{args.dev}/tables_preprocessed.json'), 'r', encoding='utf-8'))
        sqls = get_sql_for_database_from_tables_json(example["db_id"], tables_json, use_column_desc=args.use_column_desc)

        prompt_info = self.template_info.format("\n\n".join(sqls))
        prompt_extra_info = self.get_extra_info(example["db_id"])

        if example['instance_id'].startswith('local'):
            dialect = 'SQLite'
        elif example['instance_id'].startswith('bq') or example['instance_id'].startswith('ga'):
            dialect = 'Goole BigQuery'
        elif example['instance_id'].startswith('sf'):
            dialect = 'Snowflake'
        else:
            raise NotImplementedError
        prompt_question = self.template_question_optimized.format(dialect, dialect, example["question"])

        def check_length(prompt_components, new):
            result = "\n\n".join(prompt_components) + prompt_question + new  # type: str
            return len(result) < 1048576 - 1000 and len(tiktoken.get_encoding("cl100k_base").encode(result)) < 128000 - 1000

        prompt_components = [prompt_info]
        original_len = len(prompt_info)
        i = 1
        while not check_length(prompt_components, ""): 
            print('>>>database schema is too long. hard truncate.')
            prompt_components = [prompt_info[:int(original_len * (1 - i / 20))]]
            i += 1

        if args.use_sample_rows:
            sample_rows = get_sample_rows_for_database_from_tables_json(example["db_id"], tables_json)  
            new = self.sample_rows_info.format(sample_rows)
            if check_length(prompt_components, new):
                prompt_components.append(new)
            else:
                print("Sample rows info too long, skip. length: ", len(new))
        if args.use_external_knowledge and example['external_knowledge'] is not None:
            with open(osp.join(proj_dir, '../../resource/documentation/external_knowledge', example['external_knowledge']), "r", encoding="utf-8") as file:
                content = file.read()
            new = self.external_knowledge_info.format(content)
            if check_length(prompt_components, new):
                prompt_components.append(new)
            else:
                print("External knowledge too long, skip. length: ", len(new))
            
        if args.use_special_function and example['special_function'] is not None:
            strs = [f"{item['name']}: {item['summary']}" for item in example['special_function']]
            special_function = "\n".join(strs)
            new = self.special_function_info.format(special_function)
            if check_length(prompt_components, new):
                prompt_components.append(new)
            else:
                print("Special functions info too long, skip. length: ", len(new))
        if args.use_plan and example['plan'] is not None:
            new = self.plan_info.format(example['plan'])
            if check_length(prompt_components, new):
                prompt_components.append(new)
            else:
                print("Plan too long, skip. length: ", len(new))

        if args.use_few_shot:  # put few-shot examples at the end. for fair comparison 
            with open(osp.join(proj_dir, '../utils/3-shot.txt'), 'r', encoding='utf-8') as file:
                new = file.read()
            if check_length(prompt_components, new):
                prompt_components.append(new)
            else:
                print("Few-shot examples too long, skip. length: ", len(new))

        if not (prompt_extra_info is None or prompt_extra_info == ""):
            new = prompt_extra_info
            if check_length(prompt_components, new):
                prompt_components.append(new)
            else:
                print("Extra info too long, skip")

        prompt_components.append(prompt_question)

        prompt = "\n\n".join(prompt_components) 
        return prompt


class TextPrompt(BasicPrompt):
    template_info = "Given the following database schema:\n" \
                  "{}"
    template_question = "Answer the following: {}"

    def format_question(self, example: dict):
        schemas = "\n".join([f"{_.name}: {', '.join(_.schema)}" for _ in example["tables"]])

        prompt_info = self.template_info.format(schemas)
        prompt_extra_info = self.get_extra_info(example["db_id"])
        prompt_question = self.template_question.format(example["question"])

        if prompt_extra_info is None or prompt_extra_info == "":
            prompt_components = [prompt_info,prompt_question]
        else:
            prompt_components = [prompt_info, prompt_extra_info, prompt_question]

        prompt = "\n".join(prompt_components)
        return prompt


class NumberSignPrompt(BasicPrompt):
    template_info = "### Complete sqlite SQL query only and with no explanation\n" \
                    "### SQLite SQL tables, with their properties:\n" \
                    "#\n" \
                    "{}\n" \
                    "#"
    template_question = "### {}"

    def format_question(self, example: dict):
        schemas = "\n".join([f"# {_.name}({', '.join(_.schema)})" for _ in example["tables"]])

        prompt_info = self.template_info.format(schemas)
        prompt_extra_info = self.get_extra_info(example["db_id"])
        prompt_question = self.template_question.format(example["question"])

        if prompt_extra_info is None or prompt_extra_info == "":
            prompt_components = [prompt_info,prompt_question]
        else:
            prompt_components = [prompt_info, prompt_extra_info, prompt_question]

        prompt = "\n".join(prompt_components)
        return prompt


class BaselinePrompt(BasicPrompt):
    template_info = "{}\nForeign_keys={}\n"
    template_question = "Q: \"{}\""

    def format_question(self, example: dict):
        # schemas
        schemas = "\n".join([f"Table {_.name}, columns = {_.schema}" for _ in example["tables"]]).replace("'", "")
        # foreign_keys
        foreign_keys = list()
        for table in example["tables"]:
            for pair_str in table["table_info"]["foreign_key"]:
                a, b = [_.strip() for _ in pair_str[1:-1].split(",")]
                foreign_keys.append(f"{a}={b}")

        # format prompt
        prompt_info = self.template_info.format(schemas, str(foreign_keys).replace("'", ""))
        prompt_extra_info = self.get_extra_info(example["db_id"])
        prompt_question = self.template_question.format(example["question"])

        if prompt_extra_info is None or prompt_extra_info == "":
            prompt_components = [prompt_info,prompt_question]
        else:
            prompt_components = [prompt_info, prompt_extra_info, prompt_question]

        prompt = "".join(prompt_components)
        return prompt

    def format_target(self, example: dict):
        return self.format_question(example) + "\nA: SELECT "


class InstructionPrompt(BasicPrompt):
    template_info = (
        "Below is an instruction that describes a task, paired with an input that provides further context. "
        "Write a response that appropriately completes the request.\n\n"
        "### Instruction:\nWrite a sql to answer the question \"{}\"\n\n### Input:\n{}\n"
    )
    template_question = "### Response:"

    def format_question(self, example: dict):
        schemas = "\n".join([f"{_.name}({', '.join(_.schema)})" for _ in example["tables"]])

        prompt_info = self.template_info.format(example["question"], schemas)
        prompt_extra_info = self.get_extra_info(example["db_id"])
        prompt_question = self.template_question

        if prompt_extra_info is None or prompt_extra_info == "":
            prompt_components = [prompt_info, prompt_question]
        else:
            # TODO: extra_info should be after info
            prompt_components = [prompt_info, prompt_extra_info, prompt_question]

        prompt = "\n".join(prompt_components)
        return prompt


class TextWithForeignKeyPrompt(BasicPrompt):
    template_info = "Given the following database schema:\n" \
                    "{} \n" \
                    "And their foreign keys:\n" \
                    "{}"
    template_question = "Answer the following: {}"

    def format_question(self, example: dict):
        schemas = "\n".join([f"{_.name}: {', '.join(_.schema)}" for _ in example["tables"]])
        # foreign_keys
        foreign_keys = list()
        for table in example["tables"]:
            for pair_str in table["table_info"]["foreign_key"]:
                a, b = [_.strip() for _ in pair_str[1:-1].split(",")]
                foreign_keys.append(f"{a}={b}")
        foreign_keys = f"{', '.join(foreign_keys)}"

        prompt_info = self.template_info.format(schemas, foreign_keys)
        prompt_extra_info = self.get_extra_info(example["db_id"])
        prompt_question = self.template_question.format(example["question"])

        if prompt_extra_info is None or prompt_extra_info == "":
            prompt_components = [prompt_info,prompt_question]
        else:
            prompt_components = [prompt_info, prompt_extra_info, prompt_question]

        prompt = "\n".join(prompt_components)
        return prompt


class NumberSignWithForeignKeyPrompt(BasicPrompt):
    template_info = "### Complete sqlite SQL query only and with no explanation\n" \
                    "### SQLite SQL tables, with their properties:\n" \
                    "#\n" \
                    "{}\n" \
                    "#\n" \
                    "### Their foreign keys:\n" \
                    "#\n" \
                    "{}\n" \
                    "#"
    template_question = "### {}"

    def format_question(self, example: dict):
        schemas = "\n".join([f"# {_.name}({', '.join(_.schema)})" for _ in example["tables"]])
        # foreign_keys
        foreign_keys = list()
        for table in example["tables"]:
            for pair_str in table["table_info"]["foreign_key"]:
                a, b = [_.strip() for _ in pair_str[1:-1].split(",")]
                foreign_keys.append(f"{a}={b}")
        foreign_keys = f"# Foreign_keys=({', '.join(foreign_keys)})"

        prompt_info = self.template_info.format(schemas, foreign_keys)
        prompt_extra_info = self.get_extra_info(example["db_id"])
        prompt_question = self.template_question.format(example["question"])

        if prompt_extra_info is None or prompt_extra_info == "":
            prompt_components = [prompt_info, prompt_question]
        else:
            prompt_components = [prompt_info, prompt_extra_info, prompt_question]

        prompt = "\n".join(prompt_components)
        return prompt


class BaselineWithoutForeignKeyPrompt(BasicPrompt):
    template_info = "{}\n"
    template_question = "Q: \"{}\""

    def format_question(self, example: dict):
        # schemas
        schemas = "\n".join([f"Table {_.name}, columns = {_.schema}" for _ in example["tables"]]).replace("'", "")

        # format prompt
        prompt_info = self.template_info.format(schemas)
        prompt_extra_info = self.get_extra_info(example["db_id"])
        prompt_question = self.template_question.format(example["question"])

        if prompt_extra_info is None or prompt_extra_info == "":
            prompt_components = [prompt_info,prompt_question]
        else:
            prompt_components = [prompt_info, prompt_extra_info, prompt_question]

        prompt = "".join(prompt_components)
        return prompt

    def format_target(self, example: dict):
        return self.format_question(example) + "\nA: SELECT "


class InstructionWithForeignKeyPrompt(BasicPrompt):
    template_info = (
        "Below is an instruction that describes a task, paired with an input that provides further context. "
        "Write a response that appropriately completes the request.\n\n"
        "### Instruction:\nWrite a sql to answer the question \"{}\"\n\n### Input:\n{}\nForeign Keys:{}\n"
    )
    template_question = "### Response:"

    def format_question(self, example: dict):
        schemas = "\n".join([f"{_.name}({', '.join(_.schema)})" for _ in example["tables"]])
        # foreign_keys
        foreign_keys = list()
        for table in example["tables"]:
            for pair_str in table["table_info"]["foreign_key"]:
                a, b = [_.strip() for _ in pair_str[1:-1].split(",")]
                foreign_keys.append(f"{a}={b}")
        foreign_keys = f"{', '.join(foreign_keys)}"

        prompt_info = self.template_info.format(example["question"], schemas, foreign_keys)
        prompt_extra_info = self.get_extra_info(example["db_id"])
        prompt_question = self.template_question

        if prompt_extra_info is None or prompt_extra_info == "":
            prompt_components = [prompt_info, prompt_question]
        else:
            # TODO: extra_info should be after info
            prompt_components = [prompt_info, prompt_extra_info, prompt_question]

        prompt = "\n".join(prompt_components)
        return prompt


class SQLWithRulePrompt(BasicPrompt):
    template_info =   "/* Given the following database schema: */\n" \
                      "{}"
    template_question =  "/* Answer the following with no explanation: {} */"

    def format_question(self, example: dict, args):
        tables_json = json.load(open(osp.join(proj_dir, f'preprocessed_data/{args.dev}/tables_preprocessed.json', 'r', encoding='utf-8')))
        sqls = get_sql_for_database_from_tables_json(example["db_id"], tables_json)

        prompt_info = self.template_info.format("\n\n".join(sqls))
        prompt_extra_info = self.get_extra_info(example["db_id"])
        prompt_question = self.template_question.format(example["question"])

        if prompt_extra_info is None or prompt_extra_info == "":
            prompt_components = [prompt_info, prompt_question]
        else:
            prompt_components = [prompt_info, prompt_extra_info, prompt_question]

        prompt = "\n\n".join(prompt_components)
        return prompt


class TextWithRulePrompt(BasicPrompt):
    template_info = "Given the following database schema:\n" \
                  "{}"
    template_question = "Answer the following with no explanation: {}"

    def format_question(self, example: dict):
        schemas = "\n".join([f"{_.name}: {', '.join(_.schema)}" for _ in example["tables"]])

        prompt_info = self.template_info.format(schemas)
        prompt_extra_info = self.get_extra_info(example["db_id"])
        prompt_question = self.template_question.format(example["question"])

        if prompt_extra_info is None or prompt_extra_info == "":
            prompt_components = [prompt_info,prompt_question]
        else:
            prompt_components = [prompt_info, prompt_extra_info, prompt_question]

        prompt = "\n".join(prompt_components)
        return prompt


class NumberSignWithoutRulePrompt(BasicPrompt):
    template_info = "### Complete sqlite SQL query\n" \
                    "### SQLite SQL tables, with their properties:\n" \
                    "#\n" \
                    "{}\n" \
                    "#"
    template_question = "### {}"

    def format_question(self, example: dict):
        schemas = "\n".join([f"# {_.name}({', '.join(_.schema)})" for _ in example["tables"]])

        prompt_info = self.template_info.format(schemas)
        prompt_extra_info = self.get_extra_info(example["db_id"])
        prompt_question = self.template_question.format(example["question"])

        if prompt_extra_info is None or prompt_extra_info == "":
            prompt_components = [prompt_info,prompt_question]
        else:
            prompt_components = [prompt_info, prompt_extra_info, prompt_question]

        prompt = "\n".join(prompt_components)
        return prompt


class InstructionWithRulePrompt(BasicPrompt):
    template_info = (
        "Below is an instruction that describes a task, paired with an input that provides further context. "
        "Write a response that appropriately completes the request.\n\n"
        "### Instruction:\nWrite a sql only and with no explanation to answer the question \"{}\"\n\n### Input:\n{}\n"
    )
    template_question = "### Response:"

    def format_question(self, example: dict):
        schemas = "\n".join([f"{_.name}({', '.join(_.schema)})" for _ in example["tables"]])

        prompt_info = self.template_info.format(example["question"], schemas)
        prompt_extra_info = self.get_extra_info(example["db_id"])
        prompt_question = self.template_question

        if prompt_extra_info is None or prompt_extra_info == "":
            prompt_components = [prompt_info, prompt_question]
        else:
            # TODO: extra_info should be after info
            prompt_components = [prompt_info, prompt_extra_info, prompt_question]

        prompt = "\n".join(prompt_components)
        return prompt


class SQLCOTPrompt(BasicPrompt):
    template_info =   "/* Given the following database schema: */\n" \
                      "{}"
    template_question =  "/* Let's think step by step. Answer the following: {} */"

    def format_question(self, example: dict, args):
        tables_json = json.load(open(osp.join(proj_dir, f'preprocessed_data/{args.dev}/tables_preprocessed.json', 'r', encoding='utf-8')))
        sqls = get_sql_for_database_from_tables_json(example["db_id"], tables_json)

        prompt_info = self.template_info.format("\n\n".join(sqls))
        prompt_extra_info = self.get_extra_info(example["db_id"])
        prompt_question = self.template_question.format(example["question"])

        if prompt_extra_info is None or prompt_extra_info == "":
            prompt_components = [prompt_info, prompt_question]
        else:
            prompt_components = [prompt_info, prompt_extra_info, prompt_question]

        prompt = "\n\n".join(prompt_components)
        return prompt

    def format_target(self, example: dict):
        return self.format_question(example)


class TextCOTPrompt(BasicPrompt):
    template_info = "Given the following database schema:\n" \
                  "{}"
    template_question = "Let's think step by step. Answer the following: {}"

    def format_question(self, example: dict):
        schemas = "\n".join([f"{_.name}: {', '.join(_.schema)}" for _ in example["tables"]])

        prompt_info = self.template_info.format(schemas)
        prompt_extra_info = self.get_extra_info(example["db_id"])
        prompt_question = self.template_question.format(example["question"])

        if prompt_extra_info is None or prompt_extra_info == "":
            prompt_components = [prompt_info,prompt_question]
        else:
            prompt_components = [prompt_info, prompt_extra_info, prompt_question]

        prompt = "\n".join(prompt_components)
        return prompt

    def format_target(self, example: dict):
        return self.format_question(example)


class NumberSignCOTPrompt(BasicPrompt):
    template_info = "### Let's think step by step. Complete sqlite SQL query only and with no explanation\n" \
                    "### SQLite SQL tables, with their properties:\n" \
                    "#\n" \
                    "{}\n" \
                    "#"
    template_question = "### {}"

    def format_question(self, example: dict):
        schemas = "\n".join([f"# {_.name}({', '.join(_.schema)})" for _ in example["tables"]])

        prompt_info = self.template_info.format(schemas)
        prompt_extra_info = self.get_extra_info(example["db_id"])
        prompt_question = self.template_question.format(example["question"])

        if prompt_extra_info is None or prompt_extra_info == "":
            prompt_components = [prompt_info,prompt_question]
        else:
            prompt_components = [prompt_info, prompt_extra_info, prompt_question]

        prompt = "\n".join(prompt_components)
        return prompt

    def format_target(self, example: dict):
        return self.format_question(example)


class InstructionCOTPrompt(BasicPrompt):
    template_info = (
        "Below is an instruction that describes a task, paired with an input that provides further context. "
        "Write a response that appropriately completes the request.\n\n"
        "### Instruction:\nLet's think step by step. Write a sql to answer the question \"{}\"\n\n### Input:\n{}\n"
    )
    template_question = "### Response:"

    def format_question(self, example: dict):
        schemas = "\n".join([f"{_.name}({', '.join(_.schema)})" for _ in example["tables"]])

        prompt_info = self.template_info.format(example["question"], schemas)
        prompt_extra_info = self.get_extra_info(example["db_id"])
        prompt_question = self.template_question

        if prompt_extra_info is None or prompt_extra_info == "":
            prompt_components = [prompt_info, prompt_question]
        else:
            # TODO: extra_info should be after info
            prompt_components = [prompt_info, prompt_extra_info, prompt_question]

        prompt = "\n".join(prompt_components)
        return prompt

    def format_target(self, example: dict):
        return self.format_question(example)


class CBRPrompt(BasicPrompt):
    template_info = "# The following are the table names and column names needed to generate SQL:\n" \
                    "Tables: {}\n" \
                    "Columns: *, {}\n" \
                    "Foreign keys: {}"
    template_question = '# translate "{}" into SQL query only and with no explanation:'

    def format_question(self, example: dict):
        tables = ", ".join([f"{_.name}" for _ in example["tables"]])
        columns = ", ".join([f"{_.name}.{col}" for _ in example["tables"] for col in _.schema])
        # foreign_keys
        foreign_keys = list()
        for table in example["tables"]:
            for pair_str in table["table_info"]["foreign_key"]:
                a, b = [_.strip() for _ in pair_str[1:-1].split(",")]
                foreign_keys.append(f"{a}={b}")
        foreign_keys = f"{', '.join(foreign_keys)}"

        prompt_info = self.template_info.format(tables, columns, foreign_keys)
        prompt_extra_info = self.get_extra_info(example["db_id"])
        prompt_question = self.template_question.format(example["question"])

        if prompt_extra_info is None or prompt_extra_info == "":
            prompt_components = [prompt_info,prompt_question]
        else:
            prompt_components = [prompt_info, prompt_extra_info, prompt_question]

        prompt = "\n".join(prompt_components)
        return prompt