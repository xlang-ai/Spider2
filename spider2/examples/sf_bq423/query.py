import os
import pandas as pd
import snowflake.connector
import json

def load_json(filename):
    """
    Loads JSON data from the specified file.

    Args:
    filename (str): Path to the JSON file.

    Returns:
    dict: Parsed JSON data.
    """
    with open(filename, 'r') as file:
        data = json.load(file)
    return data

def query_data(sql_query, database_name, is_save, save_path="result.csv"):
    """
    Queries data from Snowflake based on the provided SQL query and handles the result.

    Args:
    sql_query (str): SQL query string to be executed.
    database_name (str): The name of the database to connect to.
    is_save (bool): If True, saves the query results to a CSV file at the specified save_path.
                    If False, prints the results to the console.
    save_path (str): The file path where the results will be saved if is_save is True. Defaults to 'result.csv'.
    """
    snowflake_credential = load_json('snowflake_credential.json')
    conn = snowflake.connector.connect(
        **snowflake_credential,
        database=database_name
    )
    cursor = conn.cursor()
    cursor.execute(sql_query)

    try:
        results = cursor.fetchall()
        columns = [desc[0] for desc in cursor.description]
        df = pd.DataFrame(results, columns=columns)
        
        if df.empty:
            print("No data found for the specified query.")
        else:
            if is_save:
                df.to_csv(save_path, index=False)
                print(f"Results saved to {save_path}")
            else:
                print(df)
    except Exception as e:
        print("Error occurred while fetching data: ", e)
    finally:
        cursor.close()
        conn.close()

if __name__ == "__main__":
    # Write your SQL query in the sql_query variable to interact with the database, example SQL query related to this task is provided below

    
    sql_query = """
        SELECT table_name, comment
        FROM "GOOGLE_ADS".INFORMATION_SCHEMA.TABLES
        WHERE table_schema = 'GOOGLE_ADS_TRANSPARENCY_CENTER';
    """
    

    database_name = 'GOOGLE_ADS'
    query_data(sql_query, database_name, is_save=True, save_path="result.csv")
