import sqlite3
import pandas as pd

SQLITE_DB_DIR = "/data/zvzv1919/Spider2/spider2-lite/resource/databases/spider2-localdb"

def query_sqlite(query: str, db: str) -> pd.DataFrame:
    # optimize possible
    conn = sqlite3.connect(f"{SQLITE_DB_DIR}/{db}.sqlite")
    try:
        return pd.read_sql_query(query, conn)
    finally:
        conn.close()

if __name__ == "__main__":
    query = '''
    WITH DateRange AS (
    SELECT '2017-01-01' AS date
    UNION ALL
    SELECT DATE(date, '+1 day')
    FROM DateRange
    WHERE date < '2018-08-29'
),
DailySales AS (
    SELECT 
        dr.date,
        SUM(oi.price) AS total_sales
    FROM DateRange dr
    LEFT JOIN order_items oi ON DATE(oi.shipping_limit_date) = dr.date
    LEFT JOIN products p ON oi.product_id = p.product_id
    WHERE p.product_category_name = 'toys'
    GROUP BY dr.date
),
PredictedSales AS (
    SELECT 
        ds.date,
        ds.total_sales,
        (ds.total_sales - LAG(ds.total_sales, 1) OVER (ORDER BY ds.date)) AS sales_diff,
        (ds.total_sales - LAG(ds.total_sales, 1) OVER (ORDER BY ds.date)) * (ds.date - LAG(ds.date, 1) OVER (ORDER BY ds.date)) AS sales_diff_product_date,
        (ds.total_sales - LAG(ds.total_sales, 1) OVER (ORDER BY ds.date)) * (ds.total_sales - LAG(ds.total_sales, 1) OVER (ORDER BY ds.date)) AS sales_diff_squared
    FROM DailySales ds
),
LinearRegression AS (
    SELECT 
        ps.date,
        ps.total_sales,
        SUM(ps.sales_diff_product_date) OVER () / SUM(ps.sales_diff_squared) OVER () AS slope,
        AVG(ps.sales_diff) OVER () AS intercept
    FROM PredictedSales ps
),
FinalSales AS (
    SELECT 
        lr.date,
        lr.total_sales,
        lr.slope * (lr.date - (SELECT MIN(date) FROM DailySales)) + lr.intercept AS predicted_sales
    FROM LinearRegression lr
),
MovingAverage AS (
    SELECT 
        fs.date,
        AVG(fs.predicted_sales) OVER (ORDER BY fs.date ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING) AS moving_average
    FROM FinalSales fs
)
SELECT 
    SUM(ma.moving_average) AS total_moving_average
FROM MovingAverage ma
WHERE ma.date BETWEEN '2018-12-05' AND '2018-12-08';
    '''
    # sql_df = query_sqlite("SELECT * FROM orders LIMIT 5", "E_commerce")
    sql_df = query_sqlite(query, "E_commerce")
    print(sql_df)