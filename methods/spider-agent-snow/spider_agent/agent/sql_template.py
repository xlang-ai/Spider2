BQ_GET_TABLES_TEMPLATE = """
import os
import pandas as pd
from google.cloud import bigquery

os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "/workspace/bigquery_credential.json"
client = bigquery.Client()

query = f\"\"\"
SELECT
    table_name, ddl
FROM
    `{database_name}.{dataset_name}.INFORMATION_SCHEMA.TABLES`
WHERE
    table_type != 'VIEW'
\"\"\"

query_job = client.query(query)

try:
    results = query_job.result().to_dataframe() 
    if results.empty:
        print("No data found for the specified query.")
    else:
        results.to_csv("{save_path}", index=False)
        print(f"DB metadata is saved to {save_path}")
except Exception as e:
    print("Error occurred while fetching data: ", e)
"""

BQ_GET_TABLE_INFO_TEMPLATE = """
import os
import pandas as pd
from google.cloud import bigquery

os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "/workspace/bigquery_credential.json"
client = bigquery.Client()

query = f\"\"\"
    SELECT field_path, data_type, description
    FROM `{database_name}.{dataset_name}.INFORMATION_SCHEMA.COLUMN_FIELD_PATHS`
    WHERE table_name = '{table}';
\"\"\"

query_job = client.query(query)

try:
    output = query_job.result().to_dataframe() 
    if output.empty:
        print("No data found for the specified query.")
    else:
        output.to_csv("{save_path}", index=False)
        print(f"Results saved to {save_path}")
except Exception as e:
    print("Error occurred while fetching data: ", e)
"""

BQ_SAMPLE_ROWS_TEMPLATE = """
import os
import pandas as pd
from google.cloud import bigquery
import json
os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "/workspace/bigquery_credential.json"
client = bigquery.Client()

query = f\"\"\"
    SELECT
    *
    FROM
    `{database_name}.{dataset_name}.{table}`
    TABLESAMPLE SYSTEM (0.0001 PERCENT)
    LIMIT {row_number};
\"\"\"

query_job = client.query(query)

try:
    output = query_job.result().to_dataframe() 
    if output.empty:
        print("No data found for the specified query.")
    else:
        sample_rows = output.to_dict(orient='records')
        json_data = json.dumps(sample_rows, indent=4, default=str)
        with open("{save_path}", 'w') as json_file: 
            json_file.write(json_data)
        print(f"Sample rows saved to {save_path}")
except Exception as e:
    print("Error occurred while fetching data: ", e)
"""

BQ_EXEC_SQL_QUERY_TEMPLATE = """
import os
import pandas as pd
from google.cloud import bigquery

os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "/workspace/bigquery_credential.json"
client = bigquery.Client()

sql_query = f\"\"\"{sql_query}\"\"\"

query_job = client.query(sql_query)

try:
    results = query_job.result().to_dataframe()
    if results.empty:
        print("No data found for the specified query.")
    else:
        if {is_save}:
            results.to_csv("{save_path}", index=False)
            print(f"Results saved to {save_path}")
        else:
            print(results)
except Exception as e:
    print("Error occurred while fetching data: ", e)
"""


SF_EXEC_SQL_QUERY_TEMPLATE = """
import os
import json
import pandas as pd
import snowflake.connector

# Load Snowflake credentials
snowflake_credential = json.load(open("/workspace/snowflake_credential.json"))

# Connect to Snowflake
conn = snowflake.connector.connect(
    **snowflake_credential
)
cursor = conn.cursor()

# Define the SQL query
sql_query = f\"\"\"


{sql_query}


\"\"\"

# Execute the SQL query
cursor.execute(sql_query)

try:
    # Fetch the results
    results = cursor.fetchall()
    columns = [desc[0] for desc in cursor.description]
    df = pd.DataFrame(results, columns=columns)

    # Check if the result is empty
    if df.empty:
        print("No data found for the specified query.")
    else:
        # Save or print the results based on the is_save flag
        if {is_save}:
            df.to_csv("{save_path}", index=False)
            print(f"Results saved to {save_path}")
        else:
            print(df)
except Exception as e:
    print("Error occurred while fetching data: ", e)
finally:
    cursor.close()
    conn.close()
"""



LOCAL_SQL_TEMPLATE = """
import pandas as pd
import os
import sqlite3
import duckdb

def detect_db_type(file_path):
    if file_path.endswith('.db') or file_path.endswith('.sqlite') :
        return 'sqlite'
    elif file_path.endswith('.duckdb'):
        return 'duckdb'
    else:
        try:
            conn = duckdb.connect(database=file_path, read_only=True)
            conn.execute('SELECT 1')
            conn.close()
            return 'duckdb'
        except:
            return 'sqlite'

def execute_sql(file_path, command, output_path_path):
    db_type = detect_db_type(file_path)
    
    # Make sure the file path is correct
    if not os.path.exists(file_path) and db_type == 'sqlite':
        print(f"ERROR: Database file not found: {{file_path}}")
        return

    # Connect to the database
    if db_type == 'sqlite':
        conn = sqlite3.connect(file_path)
    elif db_type == 'duckdb':
        conn = duckdb.connect(database=file_path, read_only=True)
    else:
        print(f"ERROR: Unsupported database type {{db_type}}")
        return
    
    try:
        # Execute the SQL command and fetch the results
        df = pd.read_sql_query(command, conn)
        
        # Check if the output should be saved to a CSV file or printed directly
        if output_path_path.lower().endswith(".csv"):
            df.to_csv(output_path_path, index=False)
            print(f"Output saved to: {{output_path_path}}")
        else:
            print(df)
    except Exception as e:
        print(f"ERROR: {{e}}")
    finally:
        # Close the connection to the database
        conn.close()

# Example usage
file_path = "{file_path}"    # Path to your database file
command = f\"\"\"{sql_command}\"\"\"    # SQL command to be executed
output_path = "{output_path}"# Path to save the output as a CSV or "directly"

execute_sql(file_path, command, output_path)
"""
