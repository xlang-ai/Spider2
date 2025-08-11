#!/usr/bin/env python3
"""
Script to execute all gold SQL queries and save results to CSV files.
Only executes queries where the corresponding CSV doesn't already exist.
"""

import os
import sys
import json
import sqlite3
import pandas as pd
from tqdm import tqdm

# Import the necessary functions directly to avoid importing the whole module
def load_jsonl_to_dict(file_path):
    data_dict = {}
    with open(file_path, 'r') as file:
        for line in file:
            data = json.loads(line)
            key = data.get('instance_id')
            if key:
                data_dict[key] = data
    return data_dict

def get_sqlite_result(db_path, query, save_dir=None, file_name="result.csv", chunksize=500):
    conn = sqlite3.connect(db_path)
    memory_conn = sqlite3.connect(':memory:')
    conn.backup(memory_conn)

    try:
        if save_dir:
            if not os.path.exists(save_dir):
                os.makedirs(save_dir)
            for i, chunk in enumerate(pd.read_sql_query(query, memory_conn, chunksize=chunksize)):
                mode = 'a' if i > 0 else 'w'
                header = i == 0
                chunk.to_csv(os.path.join(save_dir, file_name), mode=mode, header=header, index=False)
        else:
            df = pd.read_sql_query(query, memory_conn)
            return True, df
    except Exception as e:
        print(f"An error occurred: {e}")
        return False, str(e)
    finally:
        memory_conn.close()
        conn.close()
    
    return True, None

def execute_gold_sql_query(db_path, gold_sql_query, gold_sql_file_path,         gold_result_dir="/Users/shtlpmac050/Documents/Spider2/fork_spider/Spider2.0-fork/spider2-lite/evaluation_suite/gold/exec_result", chunksize=500):
    """
    Execute gold SQL query on the database and save results to gold_result_dir.
    Only executes if the corresponding CSV file doesn't already exist.
    """
    # Extract filename from SQL file path
    sql_filename = os.path.basename(gold_sql_file_path)
    # Convert .sql to .csv
    csv_filename = sql_filename.replace('.sql', '.csv')
    csv_path = os.path.join(gold_result_dir, csv_filename)
    
    # Check if CSV already exists
    if os.path.exists(csv_path):
        print(f"Gold result already exists: {csv_filename}, skipping execution to avoid data inconsistency")
        # Read and return the existing CSV
        try:
            df = pd.read_csv(csv_path)
            return True, df
        except Exception as e:
            print(f"Error reading existing CSV {csv_filename}: {e}")
            return False, str(e)
    
    # Execute the query and save results
    print(f"Executing gold query for {sql_filename}...")
    success, result = get_sqlite_result(db_path, gold_sql_query, gold_result_dir, csv_filename, chunksize)
    
    if success:
        print(f"Successfully executed and saved gold results to {csv_filename}")
    else:
        print(f"Failed to execute gold query for {sql_filename}: {result}")
    
    return success, result

def main():
    # Paths
    gold_sql_dir = "/Users/shtlpmac050/Documents/Spider2/fork_spider/Spider2.0-fork/spider2-lite/evaluation_suite/gold/sql"
    gold_result_dir = "/Users/shtlpmac050/Documents/Spider2/fork_spider/Spider2.0-fork/spider2-lite/evaluation_suite/gold/exec_result"
    
    # Load metadata
    spider2sql_metadata = load_jsonl_to_dict("spider2-lite.jsonl")
    
    # Get all SQL files
    sql_files = [f for f in os.listdir(gold_sql_dir) if f.endswith('.sql')]
    sql_files = sorted(sql_files)
    
    print(f"Found {len(sql_files)} SQL files")
    print(f"Will save results to: {gold_result_dir}")
    
    # Process each SQL file
    success_count = 0
    skip_count = 0
    error_count = 0
    
    for sql_file in tqdm(sql_files, desc="Executing gold queries"):
        # Get instance ID
        instance_id = sql_file.replace('.sql', '')
        
        # Only process local instances for now
        if instance_id.startswith('local'):
            # Check if instance exists in metadata
            if instance_id not in spider2sql_metadata:
                print(f"\nWarning: {instance_id} not found in metadata, skipping...")
                error_count += 1
                continue
            
            # Read SQL query
            sql_file_path = os.path.join(gold_sql_dir, sql_file)
            with open(sql_file_path, 'r') as f:
                gold_sql_query = f.read()
            
            # Get database path
            db_name = spider2sql_metadata.get(instance_id)['db']
            db_path = f"resource/databases/spider2-localdb/{db_name}.sqlite"
            
            # Check if database exists
            if not os.path.exists(db_path):
                print(f"\nError: Database not found for {instance_id}: {db_path}")
                error_count += 1
                continue
            
            # Execute the query
            success, result = execute_gold_sql_query(
                db_path=db_path,
                gold_sql_query=gold_sql_query,
                gold_sql_file_path=sql_file_path,
                gold_result_dir=gold_result_dir
            )
            
            if success:
                if isinstance(result, str) and "skipping execution" in result:
                    skip_count += 1
                else:
                    success_count += 1
            else:
                error_count += 1
                print(f"\nError executing {instance_id}: {result}")
        else:
            # Skip non-local instances (bq, ga, etc.)
            skip_count += 1
    
    print(f"\n\nExecution Summary:")
    print(f"Total SQL files: {len(sql_files)}")
    print(f"Successfully executed: {success_count}")
    print(f"Skipped (already exists or non-local): {skip_count}")
    print(f"Errors: {error_count}")

if __name__ == "__main__":
    main()