import json
import os
import sqlite3
import time
import pandas as pd
import snowflake.connector
from google.cloud import bigquery

SQLITE_DB_DIR = "/data/zvzv1919/Spider2/spider2-lite/resource/databases/spider2-localdb"
BIGQUERY_CREDENTIAL_PATH = "/data/zvzv1919/Spider2/bigquery_credential.json"
SNOWFLAKE_CREDENTIAL_PATH = "/data/zvzv1919/Spider2/snowflake_credential.json"

def query_sqlite(query: str, db: str, timeout_seconds: float = 300.0) -> pd.DataFrame:
    start_time = time.time()

    def progress_handler():
        if time.time() - start_time > timeout_seconds:
            return 1  # Non-zero interrupts the query
        return 0

    conn = sqlite3.connect(f"{SQLITE_DB_DIR}/{db}.sqlite")
    conn.set_progress_handler(progress_handler, 1000)  # Check every 1000 VM instructions
    try:
        return pd.read_sql_query(query, conn)
    finally:
        conn.close()

def query_snowflake(query: str, timeout_seconds: int = 300) -> pd.DataFrame:
    with open(SNOWFLAKE_CREDENTIAL_PATH) as f:
        credentials = json.load(f)
    
    conn = snowflake.connector.connect(**credentials)
    try:
        cursor = conn.cursor()
        cursor.execute(query, timeout=timeout_seconds)
        results = cursor.fetchall()
        columns = [desc[0] for desc in cursor.description]
        return pd.DataFrame(results, columns=columns)
    finally:
        conn.close()

def query_bigquery(query: str, timeout_seconds: float = 300.0) -> pd.DataFrame:
    os.environ.setdefault("GOOGLE_APPLICATION_CREDENTIALS", BIGQUERY_CREDENTIAL_PATH)
    client = bigquery.Client()
    query_job = client.query(query)
    return query_job.result(timeout=timeout_seconds).to_dataframe()

def load_sql_file(file_path: str) -> str:
    with open(file_path, "r") as file:
        return file.read()

def demo():
    # Joshua's unit test
    sqlite_timeout_query = "WITH RECURSIVE r(x) AS (SELECT 1 UNION ALL SELECT x+1 FROM r) SELECT * FROM r"
    bigquery_query = load_sql_file("/data/zvzv1919/Spider2/spider2-lite/evaluation_suite/gold/sql/bq001.sql")
    snowflake_query = load_sql_file("/data/zvzv1919/Spider2/spider2-lite/evaluation_suite/gold/sql/sf_bq017.sql")

    # timeout test
    try:
        df = query_sqlite(sqlite_timeout_query, "E_commerce", timeout_seconds=10.0)
    except Exception as e:
        print(f"sqlite timeout:{e}")
    try:
        query_bigquery(bigquery_query, timeout_seconds=1.0)
    except Exception as e:
        print(f"bigquery timeout:{e}")
    try:
        query_snowflake(snowflake_query, timeout_seconds=1)
    except Exception as e:
        print(f"snowflake timeout:{e}")

    # normal test
    df = query_snowflake(snowflake_query)
    df.to_csv("tmp_sf.csv", index=False)
    df = query_bigquery(bigquery_query)
    df.to_csv("tmp_bq.csv", index=False)

if __name__ == "__main__":
    demo()
