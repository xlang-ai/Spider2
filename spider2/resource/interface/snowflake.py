import os
import pandas as pd
import snowflake.connector
import json



def query_data(sql_query, is_save):
    snowflake_credential = json.load(open('snowflake_credential.json'))
    conn = snowflake.connector.connect(
        **snowflake_credential
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
                df.to_csv("result.csv", index=False)
                print("Results saved to result.csv")
            else:
                print(df)
    except Exception as e:
      print("Error occurred while fetching data: ", e)

if __name__ == "__main__":
    sql_query = """
        SELECT 
            COUNTRY,
            DATE_VALID_STD, 
            POSTAL_CODE, 
            DATEDIFF(day, current_date(), DATE_VALID_STD) AS DAY, 
            HOUR(TIME_INIT_UTC) AS HOUR, 
            TOT_PRECIPITATION_IN 
        FROM 
            GLOBAL_WEATHER__CLIMATE_DATA_FOR_BI.STANDARD_TILE.FORECAST_DAY 
        WHERE 
            POSTAL_CODE = '32333' 
            AND DAY = 7;
    """
    query_data(sql_query, is_save=False)
