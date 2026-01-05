import json
from concurrent.futures import ThreadPoolExecutor, as_completed

import llm
from utils import load_text, build_question_evidence, push_csv_to_huggingface
from db import query_sqlite
import pandas as pd
from tqdm import tqdm
import time
SAMPLE_SCHEMA_PATH = "schema_E_commerce.txt"
SYSTEM_TEMPLATE_PATH = "arctic_system_template.txt"
USER_TEMPLATE_PATH = "arctic_user_template.txt"
ASSISTANT_PREFIX = """Let me solve this step by step.
<think>
"""
SAMPLE_SCHEMA = load_text(SAMPLE_SCHEMA_PATH)
SAMPLE_QUESTION = '''
Can you calculate the 5-day symmetric moving average of predicted toy sales for December 5 to 8, 2018, using daily sales data from January 1, 2017, to August 29, 2018, with a simple linear regression model? Finally provide the sum of those four 5-day moving averages?
'''
BENCHMARK_JSONL_PATH = "/data/zvzv1919/Spider2/spider2-lite/spider2-lite.jsonl"
EXTERNAL_KNOWLEDGE_DIR = "/data/zvzv1919/Spider2/spider2-lite/resource/documents"
SCHEMA_DIR = "omnistyle_schema_sqlite"

def prepare_benchmark():
    '''
    Prepare the benchmark for Arctic SQL generation by 
    1. Loading the benchmark jsonl into df
    2. Loading the schema txt from the schema dir, assuming utils.generate_all_omnistyle_schemas has been run.
    3. Building the evidence_question column by calling utils.build_question_evidence.
    4. Running the Arctic inference by calling run_arctic_queries. 
    5. Extracting the SQL from the Arctic response by calling extract_sql.
    The prepared benchmark should have everything except the query execution result.
    '''
    df = pd.read_json(BENCHMARK_JSONL_PATH, lines=True)
    df = df[df['instance_id'].str.startswith('local')]
    
    # Build schema column
    df['schema'] = df['db'].apply(lambda db: load_text(f"{SCHEMA_DIR}/{db}.txt"))
    
    # Build evidence_question column
    df['evidence_question'] = df.apply(
        lambda row: build_question_evidence(
            row['question'], 
            f"{EXTERNAL_KNOWLEDGE_DIR}/{row['external_knowledge']}"
        ) if pd.notna(row['external_knowledge']) else row['question'],
        axis=1
    )
    # df = df[:10]
    # Build arctic_response column
    df = run_arctic_queries(df, max_workers=32, temperature=0.0)
    df['arctic_sql'] = df['arctic_response'].apply(extract_sql)
    return df


def run_arctic_queries(
    df: pd.DataFrame,
    max_workers: int = 10,
    temperature: float = 0.0,
) -> pd.DataFrame:

    df['arctic_response'] = None
    df['execution_time'] = None
    def query_row(idx: int, schema: str, evidence_question: str) -> tuple[int, str]:
        """Query a single row and return (index, response, execution_time)."""
        start_time = time.time()
        response = query_arctic(schema, evidence_question, temperature=temperature)
        end_time = time.time()
        execution_time = end_time - start_time
        return idx, response, execution_time
    
    # Run parallel queries
    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        futures = {
            executor.submit(query_row, idx, row['schema'], row['evidence_question']): idx
            for idx, row in df.iterrows()
        }
        
        for future in tqdm(as_completed(futures), total=len(futures), desc="Running Arctic queries"):
            try:
                idx, response, execution_time = future.result()
                df.at[idx, 'arctic_response'] = response
                df.at[idx, 'execution_time'] = execution_time
            except Exception as e:
                idx = futures[future]
                print(f"Error processing row {idx}: {e}")
                df.at[idx, 'arctic_response'] = f"Error: {e}"
    return df

def query_arctic(
    schema: str, 
    evidence_question: str, 
    temperature: float = 0.0,
) -> str:
    user_content = load_text(USER_TEMPLATE_PATH)
    user_content = user_content.replace("{Database Schema}", schema.strip())
    user_content = user_content.replace("{evidence + question}", evidence_question.strip())
    messages = [
        {"role": "system", "content": load_text(SYSTEM_TEMPLATE_PATH)},
        {"role": "user", "content": user_content},
        {"role": "assistant", "content": ASSISTANT_PREFIX},
    ]
    response = llm.chat(messages, temperature=temperature)
    return ASSISTANT_PREFIX + response

def extract_sql(response: str) -> str:
    """Extract the SQL query from the model's <answer> section."""
    if "<answer>" in response and "</answer>" in response:
        answer_start = response.find("<answer>") + len("<answer>")
        answer_end = response.find("</answer>")
        answer = response[answer_start:answer_end]
    else:
        answer = response
    # Extract SQL from ```sql blocks
    if "```sql" in answer:
        sql_start = answer.find("```sql") + len("```sql")
        sql_end = answer.find("```", sql_start)
        return answer[sql_start:sql_end].strip()
    return ""

def generate_prediction_csvs(benchmark_df: pd.DataFrame, output_dir: str, max_workers: int = 10):
    benchmark_df['query_result'] = None
    def run_query(idx: int, instance_id: str, sql: str, db: str) -> tuple[int, str]:
        """Run a single query, save to CSV, and return (index, result_string)."""
        try:
            result_df = query_sqlite(sql, db)
            result_df.to_csv(f"{output_dir}/{instance_id}.csv", index=False)
            return idx, result_df.to_string(index=False)
        except Exception as e:
            return idx, f"Error: {e}"
    
    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        futures = [
            executor.submit(run_query, idx, row['instance_id'], row['arctic_sql'], row['db'])
            for idx, row in benchmark_df.iterrows()
        ]
        
        for future in tqdm(as_completed(futures), total=len(futures), desc="Running SQL queries"):
            idx, result = future.result()
            benchmark_df.at[idx, 'query_result'] = result
    return benchmark_df

def demo():
    print("=" * 60)
    print("Arctic SQL Generation Demo")
    print("=" * 60)
    print("\n📋 Schema:")
    print(SAMPLE_SCHEMA)
    print("\n❓ Question:")
    print(SAMPLE_QUESTION)
    print("\n🤖 Generating SQL...\n")
    
    response = query_arctic(SAMPLE_SCHEMA, SAMPLE_QUESTION)
    
    print("=" * 60)
    print("Full Response:")
    print("=" * 60)
    print(response)
    
    print("\n" + "=" * 60)
    print("Extracted SQL:")
    print("=" * 60)
    sql = extract_sql(response)
    print(sql)

if __name__ == "__main__":
    # df = prepare_benchmark()
    # df.to_csv("benchmark.csv", index=False)
    # df = pd.read_csv("benchmark.csv")
    # df = generate_prediction_csvs(df, "prediction_csvs_arctic")
    # df.to_csv("benchmark.csv", index=False)

    df = prepare_benchmark()
    df.to_csv("benchmark_1.csv", index=False)
    push_csv_to_huggingface("benchmark_1.csv", "Genies/vllm_profile", collection="Genies/text-to-sql")
