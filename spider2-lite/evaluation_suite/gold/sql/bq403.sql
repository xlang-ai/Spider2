WITH RankedData AS (
    SELECT
        CONCAT("20", _TABLE_SUFFIX) AS year_filed,
        totrevenue,
        totfuncexpns,
        ROW_NUMBER() OVER (PARTITION BY CONCAT("20", _TABLE_SUFFIX) ORDER BY totrevenue) 
        AS revenue_rank,
        ROW_NUMBER() OVER (PARTITION BY CONCAT("20", _TABLE_SUFFIX) ORDER BY totfuncexpns) 
        AS expense_rank,
        COUNT(*) OVER (PARTITION BY CONCAT("20", _TABLE_SUFFIX)) AS total_count
    FROM 
        `bigquery-public-data.irs_990.irs_990_20*`
),

YearlyMedians AS (
    SELECT
        year_filed,
        IF(MOD(total_count, 2) = 1, 
           MAX(CASE WHEN revenue_rank = (total_count + 1) / 2 THEN totrevenue END),
           AVG(CASE WHEN revenue_rank IN ((total_count / 2), (total_count / 2) + 1) THEN totrevenue END)
        ) AS median_revenue,
        IF(MOD(total_count, 2) = 1, 
           MAX(CASE WHEN expense_rank = (total_count + 1) / 2 THEN totfuncexpns END),
           AVG(CASE WHEN expense_rank IN ((total_count / 2), (total_count / 2) + 1) THEN totfuncexpns END)
        ) AS median_expense
    FROM
        RankedData
    GROUP BY
        year_filed, total_count
),

DifferenceCalculations AS (
    SELECT
        year_filed,
        median_revenue,
        median_expense,
        ABS(median_revenue - median_expense) AS difference
    FROM
        YearlyMedians
)

SELECT
    year_filed,
    difference
FROM
    DifferenceCalculations
WHERE
    year_filed BETWEEN '2012' AND '2017'
ORDER BY
    difference ASC
LIMIT 3;