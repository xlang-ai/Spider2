import glob
import json
import pickle
import os
import os.path as osp
import numpy as np
from datetime import date
import argparse
import matplotlib.pyplot as plt

proj_dir = osp.dirname(osp.abspath(__file__))

def read_jsonl(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        return [json.loads(line) for line in file]

def get_special_function_summary(data):
    with open(osp.join(proj_dir, '../../resource/syntax/bigquery_functions/bigquery_functions.json'), 'r', encoding='utf-8') as file:
        bigquery_functions = json.load(file)

    function_summaries = {}
    for category_entry in bigquery_functions:
        category = category_entry.get("category", "")
        for function_name, function_details in category_entry.get("functions", {}).items():
            function_summaries[f"{category}/{function_name}"] = function_details.get("summary", "")
            function_summaries[function_name] = function_details.get("summary", "")  

    for item in data:
        if item.get("special_function") is None:
            continue
        updated_special_function = []
        for function_name in item.get("special_function", []):
            summary = function_summaries.get(function_name, "No summary found")
            updated_special_function.append(
                {
                    'name':function_name,
                    'summary':summary
                }
            )
        item["special_function"] = updated_special_function

    return data

def column_description_length_histogram():
    '''
    1106 status: deprecated. should be compatible with the new metadata format.
    '''
    json_path = "../../databases/bigquery/metadata/bigquery-public-data/**/*.json"

    description_lengths = []

    all_count, valid_count = 0, 0
    for json_file in glob.glob(json_path, recursive=True):
        with open(json_file, 'r', encoding='utf-8') as file:
            try:
                data = json.load(file)
                if "description" in data:
                    for desc in data["description"]:
                        all_count += 1
                        if desc is not None and desc != '':
                            valid_count += 1
                            description_lengths.append(len(desc))
            except json.JSONDecodeError:
                print(f"Error reading {json_file}")

    print(f"Total number of column descriptions: {all_count}")
    print(f"Number of valid column descriptions: {valid_count}")
    print(f"Ratio of valid column descriptions: {valid_count / all_count}")            

    plt.hist(description_lengths, bins=20, edgecolor='black')
    plt.xlabel('Description Length')
    plt.ylabel('Frequency')
    plt.title('Distribution of Column Description Lengths')
    # plt.savefig(osp.join(proj_dir, 'description_length_histogram.png'))
    # plt.show()


def db_stats(db_stats_list):
    total_table_count = sum(item['db_stats']["No. of tables"] for item in db_stats_list)
    total_column_count = sum(item['db_stats']["No. of columns"] for item in db_stats_list)
    total_avg_column_per_table = sum(item['db_stats']["Avg. No. of columns per table"] for item in db_stats_list)

    num_dbs = len(db_stats_list)

    avg_table_count_per_db = total_table_count / num_dbs if num_dbs > 0 else 0
    avg_total_column_count_per_db = total_column_count / num_dbs if num_dbs > 0 else 0
    avg_avg_column_per_table_per_db = total_avg_column_per_table / num_dbs if num_dbs > 0 else 0

    print(f"No. of db: {num_dbs}")
    print(f"Average No. of tables across all database: {avg_table_count_per_db:.2f}")
    print(f"Average No. of columns across all Database: {avg_total_column_count_per_db:.2f}")
    print(f"Average Avg. No. of columns per table across all Databases: {avg_avg_column_per_table_per_db:.2f}")


def db_stats_bar_chart(db_stats_list):

    db_ids = [item['db_id'] for item in db_stats_list]
    table_counts = [item['db_stats']["No. of tables"] for item in db_stats_list]
    total_columns = [item['db_stats']["No. of columns"] for item in db_stats_list]
    avg_columns = [item['db_stats']["Avg. No. of columns per table"] for item in db_stats_list]

    fig, ax = plt.subplots(3, 1, figsize=(10, 10))

    # Plot for table count
    ax[0].bar(db_ids, table_counts, color='blue')
    ax[0].set_title("No. of tables")
    ax[0].set_ylabel("#")
    ax[0].tick_params(axis='x', rotation=45)
    for label in ax[0].get_xticklabels():
        label.set_ha('right')

    # Plot for total column count
    ax[1].bar(db_ids, total_columns, color='green')
    ax[1].set_title("No. of columns")
    ax[1].set_ylabel("#")
    ax[1].tick_params(axis='x', rotation=45)
    for label in ax[1].get_xticklabels():
        label.set_ha('right')

    # Plot for average columns per table
    ax[2].bar(db_ids, avg_columns, color='orange')
    ax[2].set_title("Avg. No. of columns per table")
    ax[2].set_ylabel("#")
    ax[2].tick_params(axis='x', rotation=45)
    for label in ax[2].get_xticklabels():
        label.set_ha('right')

    plt.tight_layout()
    # plt.show()
    # plt.savefig(osp.join(proj_dir, 'db_statistic.png'))



def walk_metadata(dev):

    dev_data = read_jsonl(osp.join(proj_dir, f'../../{dev}.jsonl'))
        
    required_db_ids = set([item['db'] for item in dev_data])
  
    # currently supporting only bigquery, sqlite and snowflake
    db_base_paths = ["../../resource/databases/bigquery/", "../../resource/databases/sqlite/", "../../resource/databases/snowflake/"]
    json_glob_path = "**/*.json"

    db_stats_list = []
    for base_path in db_base_paths:
        for db_path in glob.glob(os.path.join(base_path, "*"), recursive=False):

            db_id = os.path.basename(os.path.normpath(db_path)) 
            if db_id not in required_db_ids:
                    continue

            table_count = 0
            total_column_count = 0

            table_names_original = []
            column_names_original = []
            column_types = []
            descriptions = []
            sample_rows = {}
            table_to_projDataset = {}

            for json_file in glob.glob(os.path.join(db_path, json_glob_path), recursive=True):
                with open(json_file, 'r', encoding='utf-8') as file:
                    try:
                        data = json.load(file)

                        table_count += 1
                        table_name = data.get("table_name", "")
                        table_names_original.append(table_name)
                        
                        if 'bigquery' in base_path:  # bikeshare_trips: bigquery-public-data.austin_bikeshare
                            table_to_projDataset[table_name] = osp.basename(osp.dirname(json_file))  
                        elif 'snowflake' in base_path:  # HISTORY_DAY: GLOBAL_WEATHER__CLIMATE_DATA_FOR_BI.STANDARD_TILE
                            table_to_projDataset[table_name] = osp.basename(osp.dirname(osp.dirname(json_file))) + '.' + osp.basename(osp.dirname(json_file))
                        elif 'sqlite' in base_path:  # local
                            table_to_projDataset[table_name] = None  # we will not read it.
                        else:
                            raise ValueError(f"Unknown database type: {base_path}")

                        columns = data.get("column_names", [])
                        column_types_in_table = data.get("column_types", [])
                        descriptions_in_table = data.get("description", [])

                        total_column_count += len(columns)

                        for col_index, col_name in enumerate(columns):
                            column_names_original.append([table_count - 1, col_name])

                        column_types.extend(column_types_in_table)

                        for desc in descriptions_in_table:
                            descriptions.append([table_count - 1, desc])

                        if "sample_rows" in data:
                            sample_rows[table_name] = data["sample_rows"]

                    except json.JSONDecodeError:
                        print(f"Error reading {json_file}")

            avg_column_per_table = total_column_count / table_count if table_count > 0 else 0

            # TODO deprecated in 1106
            # if 'bigquery' in base_path:
            #     db_id = f"{project_name}.{db_id}"
            # elif 'sqlite' in base_path:
            #     db_id = db_id
            # elif 'snowflake' in base_path:
            #     db_id = f"{project_name}.{db_id}" 
            # else:
            #     raise ValueError(f"Unknown database type: {base_path}")

            db_stats_list.append({
                "db_id": db_id,
                "db_stats": {
                    "No. of tables": table_count,
                    "No. of columns": total_column_count,
                    "Avg. No. of columns per table": avg_column_per_table
                },
                "table_names_original": table_names_original,
                "column_names_original": column_names_original,
                "column_types": column_types,
                "column_descriptions": descriptions,
                "sample_rows": sample_rows,
                "primary_keys": [], 
                "foreign_keys": [],  
                "table_to_projDataset": table_to_projDataset
            })


    db_stats(db_stats_list)
    db_stats_bar_chart(db_stats_list)
    return db_stats_list


if __name__ == '__main__':
    column_description_length_histogram()