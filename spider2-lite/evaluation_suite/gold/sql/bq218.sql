WITH AnnualSales AS (
  SELECT
    item_description,
    EXTRACT(YEAR FROM date) AS year,
    SUM(sale_dollars) AS total_sales_revenue,
    COUNT(DISTINCT invoice_and_item_number) AS unique_purchases
  FROM
    `bigquery-public-data.iowa_liquor_sales.sales`
  WHERE
    EXTRACT(YEAR FROM date) IN (2022, 2023)
    AND item_description IS NOT NULL
    AND sale_dollars IS NOT NULL
  GROUP BY
    item_description, year
),
YoYGrowth AS (
  SELECT
    curr.item_description,
    curr.year,
    curr.total_sales_revenue,
    curr.unique_purchases,
    LAG(curr.total_sales_revenue) OVER(PARTITION BY curr.item_description ORDER BY curr.year) AS prev_year_sales_revenue,
    (curr.total_sales_revenue - LAG(curr.total_sales_revenue) OVER(PARTITION BY curr.item_description ORDER BY curr.year)) / LAG(curr.total_sales_revenue) OVER(PARTITION BY curr.item_description ORDER BY curr.year) * 100 AS yoy_growth_percentage
  FROM
    AnnualSales curr
),
total_info AS (
SELECT
  item_description,
  year,
  total_sales_revenue,
  unique_purchases,
  prev_year_sales_revenue,
  yoy_growth_percentage
FROM
  YoYGrowth
WHERE
  year = 2023
  AND prev_year_sales_revenue IS NOT NULL -- Exclude rows where there's no previous year data to calculate YoY growth
ORDER BY
  year, total_sales_revenue 
DESC
)

SELECT item_description
FROM total_info
order by yoy_growth_percentage
DESC
LIMIT 5