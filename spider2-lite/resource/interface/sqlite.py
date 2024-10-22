import sqlite3
import pandas as pd

def query_database_pandas(db_path, query):
    conn = sqlite3.connect(db_path)
    
    try:
        # Execute SQL query using pandas and retrieve the results
        df = pd.read_sql_query(query, conn)
        
        # Print the results
        print(df.to_string(index=False))
        
    except sqlite3.Error as e:
        print(f"An error occurred: {e}")
    
    finally:
        # Close the database connection
        conn.close()


# Path to the database file
database_path = ""

# SQL query
sql_query = """

"""

query_database_pandas(database_path, sql_query)
