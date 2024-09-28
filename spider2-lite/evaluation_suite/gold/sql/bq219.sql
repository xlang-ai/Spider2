WITH
MonthlyTotals AS
(
  SELECT
    FORMAT_DATE('%Y-%m', date) AS month,
    SUM(volume_sold_gallons) AS total_monthly_volume

  FROM
    `bigquery-public-data.iowa_liquor_sales.sales`

  WHERE
    # Start w/ date given by query parameter
    date >= "2022-01-01" AND
    # Remove current month so as to avoid partial data
    FORMAT_DATE('%Y-%m', date) < FORMAT_DATE('%Y-%m', CURRENT_DATE())
    
  GROUP BY
    month
),

MonthCategory AS
(
  SELECT
    FORMAT_DATE('%Y-%m', date) AS month,
    category,
    category_name,

    SUM(volume_sold_gallons) AS category_monthly_volume,

    SAFE_DIVIDE(
      SUM(volume_sold_gallons),
      total_monthly_volume
      ) * 100 AS category_pct_of_month_volume

  FROM
    `bigquery-public-data.iowa_liquor_sales.sales` Sales
    
  LEFT JOIN
    MonthlyTotals ON 
      FORMAT_DATE('%Y-%m', Sales.date) = MonthlyTotals.month

  WHERE
    # Start w/ date given by query parameter
    date >= "2022-01-01" AND    
    # Remove current month so as to avoid partial data
    FORMAT_DATE('%Y-%m', date) < FORMAT_DATE('%Y-%m', CURRENT_DATE())

  GROUP BY
    month, category, category_name, total_monthly_volume
),

middle_info AS (
SELECT
  Category1.category AS category1,
  Category1.category_name AS category_name1,

  Category2.category AS category2,
  Category2.category_name AS category_name2,

  COUNT(DISTINCT Category1.month) AS num_months,

  CORR(
    Category1.category_pct_of_month_volume,
    Category2.category_pct_of_month_volume
    ) AS category_corr_across_months,

  AVG(Category1.category_pct_of_month_volume) AS
    category1_avg_pct_of_month_volume,
  AVG(Category2.category_pct_of_month_volume) AS
    category2_avg_pct_of_month_volume

FROM
  MonthCategory Category1

INNER JOIN
  MonthCategory Category2 ON
  (
    Category1.month = Category2.month
  )

GROUP BY
  category1, category_name1, category2, category_name2

HAVING
  num_months >= 24 AND
  category1_avg_pct_of_month_volume >= 1 AND
  category2_avg_pct_of_month_volume >= 1
  
)

SELECT category_name1, category_name2
FROM middle_info
ORDER BY category_corr_across_months
LIMIT 1
