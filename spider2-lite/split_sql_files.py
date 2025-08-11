import os
import csv
from typing import List

def extract_sql_from_csv(csv_file: str) -> List[str]:
    """Extract SQL queries from CSV file's 'sql' column."""
    sql_queries = []
    try:
        with open(csv_file, 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            for row in reader:
                if 'sql' in row and row['sql']:
                    sql_queries.append(row['sql'].strip())
    except Exception as e:
        print(f"Error reading CSV file {csv_file}: {e}")
    return sql_queries

def process_sql_files(input_dir: str, output_dir: str, start_num: int = 457, end_num: int = 556):
    """
    Process CSV files from input directory and create SQL files.
    
    Args:
        input_dir: Directory containing CSV files
        output_dir: Directory where SQL files will be created
        start_num: Starting number for file naming (default: 357)
        end_num: Ending number for file naming (default: 556)
    """
    # Create output directory if it doesn't exist
    os.makedirs(output_dir, exist_ok=True)
    
    all_sql_queries = []
    
    # Process all CSV files
    for filename in os.listdir(input_dir):
        if filename.endswith('.csv'):
            csv_path = os.path.join(input_dir, filename)
            print(f"Processing CSV file: {filename}")
            sql_queries = extract_sql_from_csv(csv_path)
            all_sql_queries.extend(sql_queries)
            print(f"  Found {len(sql_queries)} SQL queries")
    
    # Create SQL files with specified naming
    total_queries = len(all_sql_queries)
    print(f"\nTotal SQL queries found: {total_queries}")
    
    if total_queries == 0:
        print("No SQL queries found!")
        return
    
    # Calculate how many files we need to create
    max_files = end_num - start_num + 1
    files_to_create = min(total_queries, max_files)
    
    print(f"Creating {files_to_create} SQL files (local{start_num}.sql to local{start_num + files_to_create - 1}.sql)")
    
    for i, sql_query in enumerate(all_sql_queries[:files_to_create]):
        file_num = start_num + i
        filename = f"local{file_num}.sql"
        filepath = os.path.join(output_dir, filename)
        
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(sql_query)
    
    print(f"\nSuccessfully created {files_to_create} SQL files in '{output_dir}' directory!")
    
    if total_queries > max_files:
        print(f"Note: {total_queries - max_files} queries were not saved due to file naming limit.")

if __name__ == "__main__":
    # Use the specified paths
    input_dir = "/Users/shtlpmac050/Documents/Spider2/fork_spider/Spider2.0-fork/spider2-lite/evaluation_suite/gold/csv"
    output_dir = "/Users/shtlpmac050/Documents/Spider2/fork_spider/Spider2.0-fork/spider2-lite/evaluation_suite/gold/sql"
    
    process_sql_files(input_dir, output_dir, start_num=457, end_num=556)