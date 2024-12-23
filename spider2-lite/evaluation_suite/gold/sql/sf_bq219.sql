WITH
MonthlyTotals AS
(
  SELECT
    TO_CHAR("date", 'YYYY-MM') AS "month",
    SUM("volume_sold_gallons") AS "total_monthly_volume"
  FROM
    IOWA_LIQUOR_SALES.IOWA_LIQUOR_SALES."SALES"
  WHERE
    "date" >= '2022-01-01' 
    AND TO_CHAR("date", 'YYYY-MM') < TO_CHAR(CURRENT_DATE(), 'YYYY-MM')
  GROUP BY
    TO_CHAR("date", 'YYYY-MM')
),

MonthCategory AS
(
  SELECT
    TO_CHAR("date", 'YYYY-MM') AS "month",
    "category",
    "category_name",
    SUM("volume_sold_gallons") AS "category_monthly_volume",
    CASE 
      WHEN "total_monthly_volume" != 0 THEN (SUM("volume_sold_gallons") / "total_monthly_volume") * 100
      ELSE NULL
    END AS "category_pct_of_month_volume"
  FROM
    IOWA_LIQUOR_SALES.IOWA_LIQUOR_SALES."SALES" AS Sales
  LEFT JOIN
    MonthlyTotals ON TO_CHAR(Sales."date", 'YYYY-MM') = MonthlyTotals."month"
  WHERE
    Sales."date" >= '2022-01-01' 
    AND TO_CHAR(Sales."date", 'YYYY-MM') < TO_CHAR(CURRENT_DATE(), 'YYYY-MM')
  GROUP BY
    TO_CHAR(Sales."date", 'YYYY-MM'), "category", "category_name", "total_monthly_volume"
),

middle_info AS 
(
  SELECT
    Category1."category" AS "category1",
    Category1."category_name" AS "category_name1",
    Category2."category" AS "category2",
    Category2."category_name" AS "category_name2",
    COUNT(DISTINCT Category1."month") AS "num_months",
    CORR(Category1."category_pct_of_month_volume", Category2."category_pct_of_month_volume") AS "category_corr_across_months",
    AVG(Category1."category_pct_of_month_volume") AS "category1_avg_pct_of_month_volume",
    AVG(Category2."category_pct_of_month_volume") AS "category2_avg_pct_of_month_volume"
  FROM
    MonthCategory Category1
  INNER JOIN
    MonthCategory Category2 
    ON Category1."month" = Category2."month"
  GROUP BY
    Category1."category", Category1."category_name", Category2."category", Category2."category_name"
  HAVING
    "num_months" >= 24
    AND "category1_avg_pct_of_month_volume" >= 1
    AND "category2_avg_pct_of_month_volume" >= 1
)

SELECT 
  "category_name1", 
  "category_name2"
FROM 
  middle_info
ORDER BY 
  "category_corr_across_months"
LIMIT 1;
