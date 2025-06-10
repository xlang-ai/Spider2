import snowflake.connector
from snowflake.connector.errors import ProgrammingError, DatabaseError
import pandas as pd
from typing import Dict, Any, Tuple
import logging
import time
import json
import os

logger = logging.getLogger(__name__)

TIMEOUT = 60
MAX_CSV_CHARS = 2000

def get_snowflake_credentials() -> Dict[str, str]:
    credentials_path = "credentials/snowflake_credential.json"
    try:
        with open(credentials_path, "r") as f:
            return json.load(f)
    except FileNotFoundError:
        logger.error(f"Credentials file not found at: {os.path.abspath(credentials_path)}")
        raise
    except json.JSONDecodeError:
        logger.error(f"Invalid JSON in credentials file: {credentials_path}")
        raise
    except Exception as e:
        logger.error(f"Error loading credentials: {str(e)}")
        raise

def execute_snowflake_sql(sql: str, **kwargs) -> Dict[str, Any]:
    logger.info(f"Executing Snowflake SQL: {sql}")
    
    timeout = kwargs.get('timeout', TIMEOUT)
    start_time = time.time()
    
    content = ""
    
    conn = None
    try:
        # Get Snowflake credentials from file
        snowflake_credential = get_snowflake_credentials()
        
        # Connect to Snowflake using credentials
        conn = snowflake.connector.connect(
            **snowflake_credential,
            login_timeout=timeout,
            network_timeout=timeout
        )
        cursor = conn.cursor()
        
        # Execute SQL query
        cursor.execute(sql)
        
        # First print success message
        print("Query executed successfully")
        
        # Fetch results if the query returns data
        if cursor.description:
            headers = [desc[0] for desc in cursor.description]
            rows = cursor.fetchall()
            if rows:
                df = pd.DataFrame(rows, columns=headers)
                
                # Convert full dataset to CSV
                full_csv_data = df.to_csv(index=False)
                total_rows = len(df)
                
                # Check if we need to truncate by character length
                if len(full_csv_data) > MAX_CSV_CHARS:
                    # Truncate to MAX_CSV_CHARS characters
                    truncated_csv = full_csv_data[:MAX_CSV_CHARS]
                    
                    # Find the last complete line to avoid cutting in the middle
                    last_newline = truncated_csv.rfind('\n')
                    if last_newline > 0:
                        truncated_csv = truncated_csv[:last_newline]
                    
                    content = f"""Query executed successfully

```csv
{truncated_csv}
```

Note: The result has been truncated to {MAX_CSV_CHARS} characters for display purposes. The complete result set contains {total_rows} rows and {len(full_csv_data)} characters."""
                else:
                    content = f"""Query executed successfully

```csv
{full_csv_data}
```"""
            else:
                content = "Query executed successfully, but no rows returned."
        else:
            conn.commit()
            content = "Query executed successfully."
        
        
    except ProgrammingError as e:
        content = f"SQL Error: {str(e)}"
        logger.error(f"Snowflake SQL error: {str(e)}")
    except DatabaseError as e:
        content = f"Database error: {str(e)}"
        logger.error(f"Snowflake database error: {str(e)}")
    except TimeoutError:
        content = f"Execution timed out after {timeout} seconds."
        logger.error(f"Snowflake query timed out: {sql}")
    except Exception as e:
        content = f"Unexpected error: {str(e)}"
        logger.error(f"Unexpected error executing Snowflake query: {str(e)}")
    finally:
        if conn:
            conn.close()
            
        # Log execution time
        execution_time = time.time() - start_time
        logger.info(f"Execution completed in {execution_time:.2f} seconds")
    
    return {
        "content": f"EXECUTION RESULT of [execute_snowflake_sql]:\n{content}"
    }

def register_tools(registry):
    registry.register_tool("execute_snowflake_sql", execute_snowflake_sql)