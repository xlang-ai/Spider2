import os
import pandas as pd
from google.cloud import bigquery

def query_data(sql_query, is_save):
    os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "bigquery_credential.json"
    client = bigquery.Client()
    query_job = client.query(sql_query)
    try:
      results = query_job.result().to_dataframe() 
      if results.empty:
        print("No data found for the specified query.")
      else:
        if is_save:
            results.to_csv("result.csv", index=False)
            print("Results saved to result.csv")
        else:
            print(results)
    except Exception as e:
      print("Error occurred while fetching data: ", e)

if __name__ == "__main__":
    sql_query = """
        SELECT
        item_id,
        item_name,
        COUNT(DISTINCT user_pseudo_id) AS user_count
        FROM
        `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`, UNNEST(items)
        WHERE
        _TABLE_SUFFIX BETWEEN '20201101' AND '20201130'
        AND event_name IN ('add_to_cart')
        GROUP BY
        1, 2
        ORDER BY
        user_count DESC
        LIMIT 10;
    """
    query_data(sql_query, is_save=False)
