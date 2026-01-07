"""
Simple multi-step SQL agent with execution feedback.
Prompts from: open-r1-0717/src/open_r1/inference_configs/spider-2-lite-bigquery.yaml
"""
import json
import re
import time
from typing import Any

import llm
from db import query_sqlite, query_bigquery, query_snowflake
from datasets import load_dataset
from concurrent.futures import ThreadPoolExecutor, as_completed
from tqdm import tqdm
import pandas as pd
from utils import push_csv_to_huggingface
# From spider-2-lite-bigquery.yaml
SYSTEM_PROMPT = """
You will craft BigQuery SQL queries to address the user's specific problems.

CRITICAL BigQuery Syntax Rules:

1. Table Format: ALL table references MUST use backticks with full 3-part names:
   `bigquery-public-data.{dataset_name}.{table_name}`
   Example: `bigquery-public-data.google_analytics_sample.ga_sessions_20170101`
   
2. Schema Discovery - Use __TABLES__ to list tables ONLY:
   SELECT table_id FROM `bigquery-public-data.{dataset_name}.__TABLES__` LIMIT 20
   IMPORTANT: __TABLES__ ONLY has table_id column. Do NOT try to SELECT column_name, data_type, etc. from __TABLES__.
   
3. Column Discovery - Query the actual table with LIMIT 1 to see all columns:
   SELECT * FROM `bigquery-public-data.{dataset_name}.{table_name}` LIMIT 1
   The returned result will show you all column names and their data types.
   DO NOT query INFORMATION_SCHEMA.COLUMNS - you don't have permission.
   
4. Wildcard Tables: For date-partitioned tables ending with dates (e.g., ga_sessions_YYYYMMDD):
   SELECT * FROM `bigquery-public-data.{dataset_name}.table_prefix_*`
   WHERE _TABLE_SUFFIX BETWEEN '20170101' AND '20170131'
   
5. Standard SQL ONLY: No Legacy SQL

NEVER use (these will cause errors):
- sqlite_master (SQLite-specific - BigQuery doesn't have this)
- PRAGMA commands (SQLite-specific)
- INFORMATION_SCHEMA.COLUMNS or INFORMATION_SCHEMA.TABLES (you don't have permission)
- Querying __TABLES__ for anything other than table_id (it only has table_id column)
- Unqualified table names (must include full path)

Example of CORRECT schema discovery workflow:
Step 1: SELECT table_id FROM `bigquery-public-data.new_york.__TABLES__` LIMIT 20
Step 2: SELECT * FROM `bigquery-public-data.new_york.citibike_trips` LIMIT 1
Step 3: Now you know all columns, write your actual query

Your task involves iterative steps. At each step, your response must be a JSON object with the following fields:

- "reasoning": Clearly explain your current understanding, your plan to approach the problem, and any adjustments based on previous results.
- "task": State the specific next step you will address in your plan.
- "sql": Provide the SQL query to execute for the task, formatted within proper SQL markdown tags:

```sql
-- Your SQL query here
```

Procedure:

First Step:

* In "reasoning", explain your overall understanding and high-level strategy.
  * Conclude by providing a numbered, step-by-step plan that covers everything needed to solve the user's problem.
* In "task", select the logical initial task from your plan.
* In "sql", write the corresponding SQL query for this initial task.

Subsequent Steps:

* Revisit and revise your plan based on the outputs from previously executed SQL queries in your "reasoning".

  * Make clear how the revised plan leads to the final answer.
  * If the problem is already solved, proceed to the **Final Step** (see below).
* Identify and clearly state your next immediate task from the updated plan in "task".

  * Each task must be solvable by a valid & executable SQL query.
* Provide the associated SQL query to execute this task in "sql".

  * Each task must be followed by a valid & executable SQL query.

Execution environment notes (respect these constraints):

* Only read-only queries are allowed (SELECT). No INSERT/UPDATE/DELETE/CREATE/DROP, etc.
* Outputs exceeding ~500 characters may be truncated.
* At most 20 rows are returned for each query ('LIMIT 20' is appended to SELECT queries if absent).
* Use __TABLES__ to discover available tables in the dataset.
* Use SELECT * LIMIT 1 to discover column names and types.
* BigQuery uses Standard SQL syntax with backtick-quoted fully qualified names.

Final Step (Mandatory):

* When you determine the problem is solved or all needed information has been gathered, you MUST perform one last step titled:
  **"Construct the final SQL query"**.

  * In "reasoning", briefly confirm that all requirements are satisfied.
  * In "task", write exactly: "Construct the final SQL query".
  * In "sql", provide the single complete SQL query that produces the final solution.
""".strip()

# From spider-2-lite-bigquery.yaml
CONTINUE_TEMPLATE = """<|im_start|>user
Here are results from last step:
```json{{
    "sql_query_executed": "```sql{sql_query}```",
    "execution_output": "{sql_exec_out}"
}}```

Now based on new information you received, revise the plan and generate sql query for next step.
Remember to return json following instructions in system prompt with fields: reasoning, task, sql
If task is already solved, provide 'N/A' for sql
<|im_end|>
<|im_start|>assistant
"""

# Defaults from spider-2-lite-bigquery.yaml
DEFAULT_DEPTH = 10      # run.depth
DEFAULT_WINDOW = 10     # run.window
DEFAULT_TEMPERATURE = 0.8  # generation.temperature



def extract_json(text: str) -> dict:
    """Extract JSON block from response."""
    try:
        start = text.find("{")
        end = text.rfind("}") + 1
        if start == -1 or end == 0:
            return {}
        parsed = json.loads(text[start:end])
        # Validate required fields
        if "reasoning" not in parsed or "task" not in parsed or "sql" not in parsed:
            return {}
        return parsed
    except json.JSONDecodeError:
        return {}

def extract_sql(text: str) -> str:
    """Extract SQL from ```sql blocks or raw text."""
    s = text.strip()
    if s.startswith("```sql"):
        s = s[6:]
        if s.endswith("```"):
            s = s[:-3]
        return s.strip()
    return s

def execute_sql(sql: str, instance_id: str, db: str, timeout: float = 300.0) -> str:
    """Execute SQL against the appropriate database based on instance_id."""
    try:
        if instance_id.startswith("local"):
            df = query_sqlite(sql, db, timeout_seconds=timeout)
        elif instance_id.startswith("bq") or instance_id.startswith("ga"):
            df = query_bigquery(sql, timeout_seconds=timeout)
        elif instance_id.startswith("sf"):
            df = query_snowflake(sql, timeout_seconds=int(timeout))
        else:
            return f"Error: Unknown instance type: {instance_id}"
        
        result = df.to_string(index=False)
        # Truncate long results (matches inference script behavior)
        if len(result) > 500:
            result = result[:500] + "\n... (truncated)"
        return result
    except Exception as e:
        return f"Error executing SQL: {e}"

def run_agent_one(
    prompt: str,
    instance_id: str,
    db: str,
    idx: int = 0, # Index of the row in the dataset, needed by run_agent_all
    depth: int = DEFAULT_DEPTH,
    window: int = DEFAULT_WINDOW,
    temperature: float = DEFAULT_TEMPERATURE,
) -> dict[str, Any]:
    start_time = time.time()
    messages_prefix = [
        {"role": "system", "content": SYSTEM_PROMPT},
        {"role": "user", "content": prompt},
    ]
    # Intermediate messages (will be windowed)
    messages_intermediate = []
    
    steps = []
    
    for step in range(depth):
        new_step = {
            "instance_id": instance_id,
            "step": step,
            "llm_messages": [],
            "llm_response": "N/A",
            "sql": "N/A",
            "sql_exec_out": "N/A",
            "solved": False,
            "llm_execution_time": "N/A",
            "sql_execution_time": "N/A",
        }

        # 1. Obtain LLM response
        new_step["llm_messages"] = messages_prefix + messages_intermediate[-2 * window:]
        llm_start_time = time.time()
        try:    
            response = llm.chat(new_step["llm_messages"], temperature=temperature)
        except Exception as e:
            response = f"Error calling LLM: {e}"
        new_step["llm_response"] = response
        new_step["llm_execution_time"] = time.time() - llm_start_time

        # 2. Parse LLM response
        parsed = extract_json(response)        
        sql_raw = parsed.get("sql", "N/A")
        task = parsed.get("task", "")
        reasoning = parsed.get("reasoning", "")
        if task == "Construct the final SQL query" and sql_raw != "N/A":
            new_step["solved"] = True
        
        # 3. Execute SQL
        new_step["sql"] = extract_sql(sql_raw)
        sql_start_time = time.time()
        new_step["sql_exec_out"] = execute_sql(new_step["sql"], instance_id, db)
        new_step["sql_execution_time"] = time.time() - sql_start_time
        
        # Add to conversation (intermediate messages)
        messages_intermediate.append({"role": "assistant", "content": response})
        messages_intermediate.append({
            "role": "user",
            "content": CONTINUE_TEMPLATE.format(sql_query=new_step["sql"], sql_exec_out=new_step["sql_exec_out"]),
        })
        steps.append(new_step)
        if new_step["solved"]:
            break
    
    execution_time = time.time() - start_time
    return {
        "idx": idx,
        "instance_id": instance_id,
        "final_sql": steps[-1]["sql"],
        "final_exec_out": steps[-1]["sql_exec_out"],
        "solved": steps[-1]["solved"],
        "num_steps": len(steps),
        "steps": steps,
        "execution_time": execution_time,
    }

def run_agent_all(dataset = "Genies/spider-2-lite-bigquery", max_workers: int = 500):
    df = load_dataset(dataset, split="train").to_pandas()
    df['final_sql'] = None
    df['final_exec_out'] = None
    df['solved'] = None
    df['num_steps'] = None
    df['execution_time'] = None
    
    all_steps = []

    # Run parallel queries
    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        futures = [
            executor.submit(run_agent_one, row['prompt'], row['id'], row['db_id'], idx)
            for idx, row in df.iterrows()
        ]
        
        for future in tqdm(as_completed(futures), total=len(futures), desc="Running agent"):
            try:               
                result = future.result()
                idx = result['idx']
                df.at[idx, 'final_sql'] = result['final_sql']
                df.at[idx, 'final_exec_out'] = result['final_exec_out']
                df.at[idx, 'solved'] = result['solved']
                df.at[idx, 'num_steps'] = result['num_steps']
                df.at[idx, 'execution_time'] = result['execution_time']                
                all_steps.extend(result['steps'])

            except Exception as e:
                print(f"Error processing row {idx}: {e}")

    steps_df = pd.DataFrame(all_steps)
    return df, steps_df

def demo():
    prompt = '''
    Solve the given problem according to instructions given above:

    ## Your SYSTEM Inputs
    1. **Actual Database Names**:
    - PATENTS

    2. **Database**: PATENTS
    3. **User Question**: Get the average number of inventors per patent and the total count of patent publications in Canada (CA) for each 5-year period from 1960 to 2020, based on publication dates. Only include patents that have at least one inventor listed, and group results by 5-year intervals (1960-1964, 1965-1969, etc.).

    ## OUTPUT FORMAT

    You should always return a json in the following format:

    ```json
    {
    "reasoning": "...",
    "task": "...",
    "sql": "```sql...```"
    }
    ```

    ## START THE WORKFLOW NOW BY PROPOSING A PLAN AND TAKING FIRST STEP TO SOLVE GIVEN SNOWFLAKE PROBLEM (in json format as mentioned above)
    '''
    result = run_openr1_agent(
        prompt=prompt,
        instance_id="sf_bq029",
        db="PATENTS",  # Not used for BigQuery
        depth=10,
        window=10,
    )
    print(json.dumps(result, indent=2))

if __name__ == "__main__":
    df, steps_df = run_agent_all()
    df.to_csv("openr1_sf.csv", index=False)
    steps_df.to_csv("openr1_sf_steps.csv", index=False)
    push_csv_to_huggingface("openr1_sf.csv", "Genies/openr1-sf", collection="Genies/text-to-sql")
    push_csv_to_huggingface("openr1_sf_steps.csv", "Genies/openr1-sf-steps", collection="Genies/text-to-sql")

