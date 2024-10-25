import collections
import json
import os
import re
import sqlite3
import pandas as pd

from transformers import AutoTokenizer
from utils.enums import LLM
from sql_metadata import Parser


class SqliteTable(dict):
    __getattr__ = dict.__getitem__
    __setattr__ = dict.__setitem__


def get_tables(path_db):
    if not os.path.exists(path_db):
        raise RuntimeError(f"{path_db} not exists")

    # init sqlite connection
    connection = sqlite3.connect(path_db)
    cur = connection.cursor()

    # extract table information
    table_info = parse_db(path_db, cur)
    # TODO: ! add here
    table_names = get_table_names(cur=cur)

    res = list()
    for table_name in table_names:
        # schema
        schema = [_[1] for _ in cur.execute(f'PRAGMA table_info("{table_name}")')]

        # data
        data = None
        # data = cur.execute(f"SELECT * FROM {table_name} LIMIT 5").fetchall()

        # append table
        res.append(
            SqliteTable(
                name=table_name,
                schema=schema,
                data=data,
                table_info=table_info.get(table_name, dict())
            )
        )

    cur.close()
    return res


def get_tables_from_tables_json(db_id, tables_json):
    for db in tables_json:
        if db["db_id"] != db_id: continue

        table_names = db["table_names_original"]
        columns = db["column_names_original"]
        primary_keys = db["primary_keys"]
        foreign_keys = db["foreign_keys"]
        
        table_info_list = []
        
        for table_index, table_name in enumerate(table_names):
            table_columns = [col[1] for col in columns if col[0] == table_index]
            table_primary_keys = [columns[pk][1] for pk in primary_keys if columns[pk][0] == table_index]
            
            table_foreign_keys = []
            for fk in foreign_keys:
                if columns[fk[0]][0] == table_index:
                    fk_column = columns[fk[0]][1]
                    ref_table = table_names[columns[fk[1]][0]]
                    ref_column = columns[fk[1]][1]
                    table_foreign_keys.append(f'({table_name}.{fk_column}, {ref_table}.{ref_column})')
            
            table_info = {
                'table_name': table_name,
                'schema': table_columns,
                'table_info': {
                    'primary_key': table_primary_keys,
                    'foreign_key': table_foreign_keys
                }
            }
            
            table_info_list.append(table_info)
            
        return table_info_list
    
    raise ValueError(f"Database '{db_id}' not found")

def parse_db(path_db, cur=None):
    """Parse the sql file and extract primary and foreign keys

    :param path_file:
    :return:
    """
    table_info = dict()
    table_names = get_table_names(path_db, cur)

    for table_name in table_names:
        pks = get_primary_key(table_name, path_db,cur)
        fks = get_foreign_key(table_name, path_db, cur)

        table_info[table_name] = {
            "primary_key": pks,
            "foreign_key": fks
        }
    return table_info


def execute_query(queries, path_db=None, cur=None):
    """Execute queries and return results. Reuse cur if it's not None.

    """
    assert not (path_db is None and cur is None), "path_db and cur cannot be NoneType at the same time"

    close_in_func = False
    if cur is None:
        con = sqlite3.connect(path_db)
        cur = con.cursor()
        close_in_func = True

    if isinstance(queries, str):
        results = cur.execute(queries).fetchall()
    elif isinstance(queries, list):
        results = list()
        for query in queries:
            res = cur.execute(query).fetchall()
            results.append(res)
    else:
        raise TypeError(f"queries cannot be {type(queries)}")

    # close the connection if needed
    if close_in_func:
        con.close()

    return results

def format_foreign_key(table_name: str, res: list):
    # FROM: self key | TO: target key
    res_clean = list()
    for row in res:
        table, source, to = row[2:5]
        row_clean = f"({table_name}.{source}, {table}.{to})"
        res_clean.append(row_clean)
    return res_clean


def get_foreign_key(table_name, path_db=None, cur=None):
    res_raw = execute_query(f'PRAGMA foreign_key_list("{table_name}")', path_db, cur)
    res = format_foreign_key(table_name, res_raw)
    return res


def get_primary_key(table_name, path_db=None, cur=None):
    res_raw = execute_query(f'PRAGMA table_info("{table_name}")', path_db, cur)
    pks = list()
    for row in res_raw:
        if row[5] == 1:
            pks.append(row[1])
    return pks


def get_table_names(path_db=None, cur=None):
    """Get names of all tables within the database, and reuse cur if it's not None

    """
    table_names = execute_query(queries="SELECT name FROM sqlite_master WHERE type='table'", path_db=path_db, cur=cur)
    table_names = [_[0] for _ in table_names]
    return table_names


def filter_json(raw_response: str) -> str:
    try:
        id_s = raw_response.index("{")
        id_e = raw_response.rindex("}")
        if id_s > id_e:
            raise ValueError("Wrong json format")
        else:
            return raw_response[id_s: id_e + 1]
    except ValueError:
        raise ValueError("Wrong json format")


def cost_estimate(n_tokens: int, model):
    return LLM.costs_per_thousand[model] * n_tokens / 1000


def get_sql_for_database(path_db=None, cur=None):
    close_in_func = False
    if cur is None:
        con = sqlite3.connect(path_db)
        cur = con.cursor()
        close_in_func = True

    table_names = get_table_names(path_db, cur)

    queries = [f"SELECT sql FROM sqlite_master WHERE tbl_name='{name}'" for name in table_names]

    sqls = execute_query(queries, path_db, cur)

    if close_in_func:
        cur.close()

    ret = [_[0][0] for _ in sqls]
    return ret

def get_sample_rows_for_database_from_tables_json(db_id, tables_json):

    def to_markdown(sample_rows):
        markdown_string = ""
        for key, data in sample_rows.items():
            df = pd.DataFrame(data)
            df = df.head(1)  # only use the first rows, avoid too long prompt
            markdown_table = df.to_markdown(index=False)
            markdown_string += f"table {key}:\n{markdown_table}\n\n"
        return markdown_string

    if isinstance(db_id, str):
        dbs = [db_id]
    elif isinstance(db_id, list):
        dbs = db_id
    else:
        raise ValueError(f"db_id should be str or list, not {type(db_id)}")

    md_rows = ''
    for db in tables_json:
        if db["db_id"] not in db_id: continue
        sample_rows = db["sample_rows"]
        md_rows += to_markdown(sample_rows)

    if md_rows == '':
        raise ValueError(f"Database '{db_id}' not found")

    return md_rows
    
def get_sql_for_database_from_tables_json(db_id, tables_json, use_column_desc=False):
    
    if isinstance(tables_json, str):
        GT_dbs = [db_id]
    elif isinstance(tables_json, list):
        GT_dbs = db_id
    else:
        raise ValueError(f"tables_json should be str or list, not {type(tables_json)}")

    for db in tables_json:
        if db["db_id"] not in GT_dbs: continue
       
        table_names = db["table_names_original"]
        columns = db["column_names_original"]
        column_types = db["column_types"]
        column_descs = db["column_descriptions"] 
        primary_keys = db["primary_keys"]
        foreign_keys = db["foreign_keys"]
        sample_rows = db["sample_rows"]
        
        if len(columns) != len(column_descs):
            COLUMN_DESC_FLAG = False
        else:
            COLUMN_DESC_FLAG = True
            
        create_statements = []
        for table_index, table_name in enumerate(table_names):

            table_columns = []
            for col in columns:
                if col[0] == table_index:
                    col_name = col[1]
                    col_type = column_types[columns.index(col)]
                    if COLUMN_DESC_FLAG:
                        col_desc = column_descs[columns.index(col)]
                        assert col_desc[0] == table_index
                        table_columns.append((col_name, col_type, col_desc[1]))
                    else:
                        table_columns.append((col_name, col_type, ''))
            
            table_primary_keys = [
                columns[pk][1] for pk in primary_keys if columns[pk][0] == table_index
            ]
            
            table_foreign_keys = []
            for fk in foreign_keys:
                if columns[fk[0]][0] == table_index:
                    fk_column = columns[fk[0]][1]
                    ref_table = table_names[columns[fk[1]][0]]
                    ref_column = columns[fk[1]][1]
                    table_foreign_keys.append(f'FOREIGN KEY ("{fk_column}") REFERENCES `{ref_table}` ("{ref_column}")')
            
            column_defs = []
            for col_name, col_type, col_desc in table_columns:
                column_def = f'"{col_name}" {col_type.upper()}'
                if use_column_desc and col_desc and col_desc != '':  # key: add column_desc
                    column_def += f' COMMENT "{col_desc}"'

                if col_name in table_primary_keys:
                    column_def += ' PRIMARY KEY'
                column_defs.append(column_def)
            
            create_statement = f'CREATE TABLE "{table_name}"\r\n(\r\n    '
            create_statement += ',\r\n    '.join(column_defs)
            
            if table_foreign_keys:
                create_statement += ',\r\n    ' + ',\r\n    '.join(table_foreign_keys)
            
            create_statement += '\r\n)'

            create_statements.append(create_statement)
        
        return create_statements
    raise ValueError(f"Database '{db_id}' not found")


def get_tokenizer(tokenizer_type: str):
    return 0
    tokenizer = AutoTokenizer.from_pretrained(tokenizer_type, use_fast=False)
    return tokenizer


def count_tokens(string: str, tokenizer_type: str=None, tokenizer=None):
    return 0
    # if tokenizer is None:
    #     tokenizer = get_tokenizer(tokenizer_type)
    #
    # n_tokens = len(tokenizer.encode(string))
    # return n_tokens


def sql_normalization(sql):
    sql = sql.strip()
    def white_space_fix(s):
        parsed_s = Parser(s)
        s = " ".join([token.value for token in parsed_s.tokens])

        return s

    # convert everything except text between single quotation marks to lower case
    def lower(s):
        in_quotation = False
        out_s = ""
        for char in s:
            if in_quotation:
                out_s += char
            else:
                out_s += char.lower()

            if char == "'":
                if in_quotation:
                    in_quotation = False
                else:
                    in_quotation = True

        return out_s

    # remove ";"
    def remove_semicolon(s):
        if s.endswith(";"):
            s = s[:-1]
        return s

    # double quotation -> single quotation
    def double2single(s):
        return s.replace("\"", "'")

    def add_asc(s):
        pattern = re.compile(r'order by (?:\w+ \( \S+ \)|\w+\.\w+|\w+)(?: (?:\+|\-|\<|\<\=|\>|\>\=) (?:\w+ \( \S+ \)|\w+\.\w+|\w+))*')
        if "order by" in s and "asc" not in s and "desc" not in s:
            for p_str in pattern.findall(s):
                s = s.replace(p_str, p_str + " asc")

        return s

    def sql_split(s):
        while "  " in s:
            s = s.replace("  ", " ")
        s = s.strip()
        i = 0
        toks = []
        while i < len(s):
            tok = ""
            if s[i] == "'":
                tok = tok + s[i]
                i += 1
                while i < len(s) and s[i] != "'":
                    tok = tok + s[i]
                    i += 1
                if i < len(s):
                    tok = tok + s[i]
                    i += 1
            else:
                while i < len(s) and s[i] != " ":
                    tok = tok + s[i]
                    i += 1
                while i < len(s) and s[i] == " ":
                    i += 1
            toks.append(tok)
        return toks

    def remove_table_alias(s):
        tables_aliases = Parser(s).tables_aliases
        new_tables_aliases = {}
        for i in range(1, 11):
            if "t{}".format(i) in tables_aliases.keys():
                new_tables_aliases["t{}".format(i)] = tables_aliases["t{}".format(i)]
        table_names = []
        for tok in sql_split(s):
            if '.' in tok:
                table_names.append(tok.split('.')[0])
        for table_name in table_names:
            if table_name in tables_aliases.keys():
                new_tables_aliases[table_name] = tables_aliases[table_name]
        tables_aliases = new_tables_aliases

        new_s = []
        pre_tok = ""
        for tok in sql_split(s):
            if tok in tables_aliases.keys():
                if pre_tok == 'as':
                    new_s = new_s[:-1]
                elif pre_tok != tables_aliases[tok]:
                    new_s.append(tables_aliases[tok])
            elif '.' in tok:
                split_toks = tok.split('.')
                for i in range(len(split_toks)):
                    if len(split_toks[i]) > 2 and split_toks[i][0] == "'" and split_toks[i][-1] == "'":
                        split_toks[i] = split_toks[i].replace("'", "")
                        split_toks[i] = split_toks[i].lower()
                    if split_toks[i] in tables_aliases.keys():
                        split_toks[i] = tables_aliases[split_toks[i]]
                new_s.append('.'.join(split_toks))
            else:
                new_s.append(tok)
            pre_tok = tok

        # remove as
        s = new_s
        new_s = []
        for i in range(len(s)):
            if s[i] == "as":
                continue
            if i > 0 and s[i-1] == "as":
                continue
            new_s.append(s[i])
        new_s = ' '.join(new_s)

        # for k, v in tables_aliases.items():
        #     s = s.replace("as " + k + " ", "")
        #     s = s.replace(k, v)

        return new_s

    processing_func = lambda x: remove_table_alias(add_asc(lower(white_space_fix(double2single(remove_semicolon(x))))))

    return processing_func(sql.strip())


def sql2skeleton(sql: str, db_schema):
    try:
        sql = sql_normalization(sql)

        table_names_original, table_dot_column_names_original, column_names_original = [], [], []
        column_names_original.append("*")
        for table_id, table_name_original in enumerate(db_schema["table_names_original"]):
            table_names_original.append(table_name_original.lower())
            table_dot_column_names_original.append(table_name_original + ".*")
            for column_id_and_name in db_schema["column_names_original"]:
                column_id = column_id_and_name[0]
                column_name_original = column_id_and_name[1]
                table_dot_column_names_original.append(table_name_original.lower() + "." + column_name_original.lower())
                column_names_original.append(column_name_original.lower())

        parsed_sql = Parser(sql)
        new_sql_tokens = []
        for token in parsed_sql.tokens:
            # mask table names
            if token.value in table_names_original:
                new_sql_tokens.append("_")
            # mask column names
            elif token.value in column_names_original \
                    or token.value in table_dot_column_names_original:
                new_sql_tokens.append("_")
            # mask string values
            elif token.value.startswith("'") and token.value.endswith("'"):
                new_sql_tokens.append("_")
            # mask positive int number
            elif token.value.isdigit():
                new_sql_tokens.append("_")
            # mask negative int number
            elif isNegativeInt(token.value):
                new_sql_tokens.append("_")
            # mask float number
            elif isFloat(token.value):
                new_sql_tokens.append("_")
            else:
                new_sql_tokens.append(token.value.strip())

        sql_skeleton = " ".join(new_sql_tokens)

        # remove JOIN ON keywords
        sql_skeleton = sql_skeleton.replace("on _ = _ and _ = _", "on _ = _")
        sql_skeleton = sql_skeleton.replace("on _ = _ or _ = _", "on _ = _")
        sql_skeleton = sql_skeleton.replace(" on _ = _", "")
        pattern3 = re.compile("_ (?:join _ ?)+")
        sql_skeleton = re.sub(pattern3, "_ ", sql_skeleton)

        # "_ , _ , ..., _" -> "_"
        while ("_ , _" in sql_skeleton):
            sql_skeleton = sql_skeleton.replace("_ , _", "_")

        # remove clauses in WHERE keywords
        ops = ["=", "!=", ">", ">=", "<", "<="]
        for op in ops:
            if "_ {} _".format(op) in sql_skeleton:
                sql_skeleton = sql_skeleton.replace("_ {} _".format(op), "_")
        while ("where _ and _" in sql_skeleton or "where _ or _" in sql_skeleton):
            if "where _ and _" in sql_skeleton:
                sql_skeleton = sql_skeleton.replace("where _ and _", "where _")
            if "where _ or _" in sql_skeleton:
                sql_skeleton = sql_skeleton.replace("where _ or _", "where _")

        # remove additional spaces in the skeleton
        while "  " in sql_skeleton:
            sql_skeleton = sql_skeleton.replace("  ", " ")

        # double check for order by
        split_skeleton = sql_skeleton.split(" ")
        for i in range(2, len(split_skeleton)):
            if split_skeleton[i-2] == "order" and split_skeleton[i-1] == "by" and split_skeleton[i] != "_":
                split_skeleton[i] = "_"
        sql_skeleton = " ".join(split_skeleton)

    except Exception as e:
        print('warning: ', e)
        sql_skeleton = " "
    return sql_skeleton


def isNegativeInt(string):
    if string.startswith("-") and string[1:].isdigit():
        return True
    else:
        return False


def isFloat(string):
    if string.startswith("-"):
        string = string[1:]

    s = string.split(".")
    if len(s) > 2:
        return False
    else:
        for s_i in s:
            if not s_i.isdigit():
                return False
        return True


def jaccard_similarity(skeleton1, skeleton2):
    tokens1 = skeleton1.strip().split(" ")
    tokens2 = skeleton2.strip().split(" ")
    total = len(tokens1) + len(tokens2)

    def list_to_dict(tokens):
        token_dict = collections.defaultdict(int)
        for t in tokens:
            token_dict[t] += 1
        return token_dict
    token_dict1 = list_to_dict(tokens1)
    token_dict2 = list_to_dict(tokens2)

    intersection = 0
    for t in token_dict1:
        if t in token_dict2:
            intersection += min(token_dict1[t], token_dict2[t])
    union = (len(tokens1) + len(tokens2)) - intersection
    return float(intersection) / union
