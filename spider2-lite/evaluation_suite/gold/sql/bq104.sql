WITH LatestWeek AS (
    SELECT
        DATE_SUB(MAX(week), INTERVAL 52 WEEK) AS last_year_week
    FROM
        `bigquery-public-data.google_trends.top_rising_terms`
),
LatestRefreshDate AS (
    SELECT
        MAX(refresh_date) AS latest_refresh_date
    FROM
        `bigquery-public-data.google_trends.top_rising_terms`
),
AggregatedData AS (
    SELECT
        term,
        week,
        ARRAY_AGG(STRUCT(IF(score IS NULL, NULL, dma_name) AS dma_name, rank, score) ORDER BY score DESC LIMIT 1) AS x
    FROM
        `bigquery-public-data.google_trends.top_rising_terms`
    WHERE
        week = (SELECT last_year_week FROM LatestWeek)
        AND refresh_date = (SELECT latest_refresh_date FROM LatestRefreshDate)
    GROUP BY
        term, week
)

SELECT
    term
FROM
    AggregatedData
ORDER BY
    (SELECT rank FROM UNNEST(x))
LIMIT 1
