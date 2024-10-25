from utils.linking_utils.spider_match_utils import match_shift

def mask_question_with_schema_linking(data_jsons, mask_tag, value_tag):
    mask_questions = []
    for data_json in data_jsons:
        sc_link = data_json["sc_link"]
        cv_link = data_json["cv_link"]
        q_col_match = sc_link["q_col_match"]
        q_tab_match = sc_link["q_tab_match"]
        num_date_match = cv_link["num_date_match"]
        cell_match = cv_link["cell_match"]
        question_for_copying = data_json["question_for_copying"]
        q_col_match, q_tab_match, cell_match = match_shift(q_col_match, q_tab_match, cell_match)

        def mask(question_toks, mask_ids, tag):
            new_question_toks = []
            for id, tok in enumerate(question_toks):
                if id in mask_ids:
                    new_question_toks.append(tag)
                else:
                    new_question_toks.append(tok)
            return new_question_toks

        num_date_match_ids = [int(match.split(',')[0]) for match in num_date_match]
        cell_match_ids = [int(match.split(',')[0]) for match in cell_match]
        value_match_q_ids = num_date_match_ids + cell_match_ids
        question_toks = mask(question_for_copying, value_match_q_ids, value_tag)

        q_col_match_ids = [int(match.split(',')[0]) for match in q_col_match]
        q_tab_match_ids = [int(match.split(',')[0]) for match in q_tab_match]
        schema_match_q_ids = q_col_match_ids + q_tab_match_ids
        question_toks = mask(question_toks, schema_match_q_ids, mask_tag)
        mask_questions.append(" ".join(question_toks))

    return mask_questions


def get_question_pattern_with_schema_linking(data_jsons):
    question_patterns = []
    for data_json in data_jsons:
        sc_link = data_json["sc_link"]
        cv_link = data_json["cv_link"]
        q_col_match = sc_link["q_col_match"]
        q_tab_match = sc_link["q_tab_match"]
        num_date_match = cv_link["num_date_match"]
        cell_match = cv_link["cell_match"]
        question_for_copying = data_json["question_for_copying"]

        def mask(question_toks, mask_ids, tag):
            new_question_toks = []
            for id, tok in enumerate(question_toks):
                if id in mask_ids:
                    new_question_toks.append(tag)
                else:
                    new_question_toks.append(tok)
            return new_question_toks

        num_date_match_ids = [int(match.split(',')[0]) for match in num_date_match]
        cell_match_ids = [int(match.split(',')[0]) for match in cell_match]
        value_match_q_ids = num_date_match_ids + cell_match_ids
        question_toks = mask(question_for_copying, value_match_q_ids, '_')

        q_col_match_ids = [int(match.split(',')[0]) for match in q_col_match]
        q_tab_match_ids = [int(match.split(',')[0]) for match in q_tab_match]
        schema_match_q_ids = q_col_match_ids + q_tab_match_ids
        question_toks = mask(question_toks, schema_match_q_ids, '_')
        question_patterns.append(" ".join(question_toks))

    return question_patterns


def get_relevant_tables(data_jsons, RELEVANT_TABLE_BADCASE, RELEVANT_TABLE_TOTALCASE):
    relevant_tables = []
    for data_json in data_jsons:
        table_names = data_json['table_names_original']
        col_to_tab = data_json['column_to_table']
        q_col_match = data_json['sc_link']['q_col_match']
        q_tab_match = data_json['sc_link']['q_tab_match']
        cell_match = data_json['cv_link']['cell_match']

        relevant_table_ids = []

        #### all relevant tables ####
        for match_key in q_col_match.keys():
            q_id = int(match_key.split(',')[0])
            t_id = col_to_tab[match_key.split(',')[1]]
            relevant_table_ids.append(t_id)
        for match_key in q_tab_match.keys():
            q_id = int(match_key.split(',')[0])
            t_id = int(match_key.split(',')[1])
            relevant_table_ids.append(t_id)
        for match_key in cell_match.keys():
            if cell_match[match_key] == "EXACTMATCH":
                q_id = int(match_key.split(',')[0])
                t_id = col_to_tab[match_key.split(',')[1]]
                relevant_table_ids.append(t_id)

        relevant_table_ids = list(set(relevant_table_ids))

        relevant_table_names = [table_names[id] for id in relevant_table_ids]
        if len(relevant_table_names) == 0:
            relevant_table_names = table_names

        relevant_tables.append(relevant_table_names)

        RELEVANT_TABLE_TOTALCASE = RELEVANT_TABLE_TOTALCASE + 1
        true_relevant_table_names = []
        query = data_json["query"].lower()
        for token in query.split():
            for table_name in table_names:
                if table_name.lower() in token.split('.'):
                    true_relevant_table_names.append(table_name)
        true_relevant_table_names = list(set(true_relevant_table_names))

        for true_table in true_relevant_table_names:
            if true_table not in relevant_table_names:
                RELEVANT_TABLE_BADCASE = RELEVANT_TABLE_BADCASE + 1
                break

    return relevant_tables, RELEVANT_TABLE_BADCASE, RELEVANT_TABLE_TOTALCASE

