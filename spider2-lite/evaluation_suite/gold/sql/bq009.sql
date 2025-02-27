WITH MONTHLY_REVENUE AS (
    SELECT 
        FORMAT_DATE("%Y%m", PARSE_DATE("%Y%m%d", date)) AS month,
        trafficSource.source AS source,
        ROUND(SUM(totals.totalTransactionRevenue) / 1000000, 2) AS revenue
    FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
    GROUP BY 1, 2
),

YEARLY_REVENUE AS (
    SELECT
        source,
        SUM(revenue) AS total_revenue
    FROM MONTHLY_REVENUE
    GROUP BY source
),

TOP_SOURCE AS (
    SELECT 
        source
    FROM YEARLY_REVENUE
    ORDER BY total_revenue DESC
    LIMIT 1
),

SOURCE_MONTHLY_REVENUE AS (
    SELECT
        month,
        source,
        revenue
    FROM MONTHLY_REVENUE
    WHERE source IN (SELECT source FROM TOP_SOURCE)
),

REVENUE_DIFF AS (
    SELECT 
        source,
        ROUND(MAX(revenue), 2) AS max_revenue,
        ROUND(MIN(revenue), 2) AS min_revenue,
        ROUND(MAX(revenue) - MIN(revenue), 2) AS diff_revenue
    FROM SOURCE_MONTHLY_REVENUE
    GROUP BY source
)

SELECT 
    source,
    diff_revenue
FROM REVENUE_DIFF;
