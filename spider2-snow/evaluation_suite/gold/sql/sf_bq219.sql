WITH MonthlyCategorySales AS (
    SELECT
        DATE_TRUNC('month', "date") AS sales_month,
        "category_name",
        SUM("volume_sold_liters") AS category_volume
    FROM "IOWA_LIQUOR_SALES"."IOWA_LIQUOR_SALES"."SALES"
    WHERE "date" >= '2022-01-01' AND "date" < '2024-09-01' AND "category_name" IS NOT NULL
    GROUP BY 1, 2
),
TotalMonthlySales AS (
    SELECT
        sales_month,
        SUM(category_volume) AS total_volume
    FROM MonthlyCategorySales
    GROUP BY 1
),
MonthlyCategoryPercentage AS (
    SELECT
        mcs.sales_month,
        mcs."category_name",
        (mcs.category_volume / tms.total_volume) AS percentage_of_volume
    FROM MonthlyCategorySales mcs
    JOIN TotalMonthlySales tms ON mcs.sales_month = tms.sales_month
),
EligibleCategories AS (
    SELECT
        "category_name"
    FROM MonthlyCategoryPercentage
    GROUP BY "category_name"
    HAVING COUNT(DISTINCT sales_month) >= 24 AND AVG(percentage_of_volume) >= 0.01
)
SELECT
    t1."category_name" AS category1,
    t2."category_name" AS category2
FROM MonthlyCategoryPercentage AS t1
JOIN MonthlyCategoryPercentage AS t2 ON t1.sales_month = t2.sales_month AND t1."category_name" < t2."category_name"
WHERE t1."category_name" IN (SELECT "category_name" FROM EligibleCategories)
  AND t2."category_name" IN (SELECT "category_name" FROM EligibleCategories)
GROUP BY 1, 2
ORDER BY CORR(t1.percentage_of_volume, t2.percentage_of_volume)
LIMIT 1;