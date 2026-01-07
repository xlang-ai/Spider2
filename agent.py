"""
Simple multi-step SQL agent with execution feedback.
Prompts from: open-r1-0717/src/open_r1/inference_configs/spider-2-lite-bigquery.yaml
"""
import json
import re
from typing import Any

import llm
from db import query_sqlite, query_bigquery, query_snowflake

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
* After this step, the process is complete. Any further steps MUST use:

  * "task": "N/A"
  * "sql": "N/A"
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
DEFAULT_MAX_TOKENS = 2048  # generation.max_tokens


def extract_json(text: str) -> dict | None:
    """Extract JSON block from response."""
    try:
        start = text.find("{")
        end = text.rfind("}") + 1
        if start == -1 or end == 0:
            return None
        parsed = json.loads(text[start:end])
        # Validate required fields
        if "reasoning" not in parsed or "task" not in parsed or "sql" not in parsed:
            return None
        return parsed
    except json.JSONDecodeError:
        return None


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
        return f"Error 500: {e}"


def run_agent(
    prompt: str,
    instance_id: str,
    db: str,
    depth: int = DEFAULT_DEPTH,
    window: int = DEFAULT_WINDOW,
    temperature: float = DEFAULT_TEMPERATURE,
) -> dict[str, Any]:
    """
    Run multi-step SQL agent.
    
    Args:
        prompt: The user's question/problem (already formatted with schema)
        instance_id: e.g. "local001", "bq001", "sf001", "ga001"
        db: Database name (for SQLite)
        depth: Maximum iterations (default: 10)
        window: Keep last 2*window messages in history (default: 10)
        temperature: LLM temperature (default: 0.8)
    
    Returns:
        dict with final_sql, steps, solved, etc.
    """
    # Initial messages (prefix that stays constant)
    messages_prefix = [
        {"role": "system", "content": SYSTEM_PROMPT},
        {"role": "user", "content": prompt},
    ]
    # Intermediate messages (will be windowed)
    messages_intermediate = []
    
    steps = []
    final_sql = None
    final_exec_out = None
    
    for step in range(depth):
        # Build full message list with windowing
        messages = messages_prefix + messages_intermediate[-2 * window:]
        
        # Get LLM response
        response = llm.chat(messages, temperature=temperature)
        
        # Parse JSON
        parsed = extract_json(response)
        if not parsed:
            steps.append({
                "step": step,
                "error": "Failed to parse JSON",
                "response": response[:500],
            })
            continue  # Try again next step
        
        sql_raw = parsed.get("sql", "N/A")
        task = parsed.get("task", "")
        
        # Check if done (task is N/A or sql is N/A)
        if sql_raw == "N/A" or task == "N/A":
            steps.append({
                "step": step,
                "reasoning": parsed.get("reasoning"),
                "task": task,
                "sql": None,
                "solved": True,
            })
            break
        
        # Extract and execute SQL
        sql = extract_sql(sql_raw)
        exec_result = execute_sql(sql, instance_id, db)
        final_sql = sql
        final_exec_out = exec_result
        
        steps.append({
            "step": step,
            "reasoning": parsed.get("reasoning"),
            "task": task,
            "sql": sql,
            "exec_out": exec_result,
        })
        
        # Check if this was the final step ("Construct the final SQL query")
        if "final" in task.lower() and "sql" in task.lower():
            steps[-1]["solved"] = True
            break
        
        # Add to conversation (intermediate messages)
        messages_intermediate.append({"role": "assistant", "content": response})
        messages_intermediate.append({
            "role": "user",
            "content": CONTINUE_TEMPLATE.format(sql_query=sql, sql_exec_out=exec_result),
        })
    
    solved = steps[-1].get("solved", False) if steps else False
    
    return {
        "final_sql": final_sql,
        "final_exec_out": final_exec_out,
        "solved": solved,
        "num_steps": len(steps),
        "steps": steps,
    }


if __name__ == "__main__":
    # Example usage
    result = run_agent(
        prompt="What are the top 5 products by sales?",
        instance_id="bq001",
        db="",  # Not used for BigQuery
        depth=10,
        window=10,
    )
    print(json.dumps(result, indent=2))
