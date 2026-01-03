import json
import llm
from utils import load_text, build_question_evidence
from db import query_sqlite
import pandas as pd

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

def get_schema_and_question_evidence(instance_id):
    with open(BENCHMARK_JSONL_PATH, "r") as f:
        for line in f:
            data = json.loads(line)
            if data["instance_id"] == instance_id:
                print(f"Extracted instance: {data}")
                return data
    return None

def prepare_benchmark():
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
    df = df[:10]
    # Build arctic_response column
    df['arctic_response'] = df.apply(
        lambda row: query_arctic(row['schema'], row['evidence_question']),
        axis=1
    )
    
    # Build arctic_sql column
    df['arctic_sql'] = df['arctic_response'].apply(extract_sql)
    
    # Run the SQL query and store the result
    def run_query(row):
        try:
            result = query_sqlite(row['arctic_sql'], row['db'])
            return result.to_string(index=False)
        except Exception as e:
            return f"Error: {e}"
    
    df['query_result'] = df.apply(run_query, axis=1)
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
        {"role": "user", "content": user_content}
        # {"role": "assistant", "content": ASSISTANT_PREFIX},
    ]
    response = llm.chat(messages, temperature=temperature)
    return response

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
    # get_schema_and_question_evidence("local019")
    df = prepare_benchmark()
    df.to_csv("benchmark.csv", index=False)
