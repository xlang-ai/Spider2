DECLARE start_date STRING DEFAULT '20170101';
DECLARE end_date STRING DEFAULT '20170630';

-- Step 1: Calculate daily, weekly, and monthly revenues for each traffic source
WITH daily_revenue AS (
    SELECT
        trafficSource.source AS source,
        date,
        SUM(productRevenue) / 1000000 AS revenue
    FROM
        `bigquery-public-data.google_analytics_sample.ga_sessions_*`,
        UNNEST (hits) AS hits,
        UNNEST (hits.product) AS product
    WHERE
        _table_suffix BETWEEN start_date AND end_date
    GROUP BY
        source, date
),
weekly_revenue AS (
    SELECT
        source,
        CONCAT(EXTRACT(YEAR FROM (PARSE_DATE('%Y%m%d', date))), 'W', EXTRACT(WEEK FROM (PARSE_DATE('%Y%m%d', date)))) AS week,
        SUM(revenue) AS revenue
    FROM daily_revenue
    GROUP BY source, week
),
monthly_revenue AS (
    SELECT
        source,
        CONCAT(EXTRACT(YEAR FROM (PARSE_DATE('%Y%m%d', date))),'0', EXTRACT(MONTH FROM (PARSE_DATE('%Y%m%d', date)))) AS month,
        SUM(revenue) AS revenue
    FROM daily_revenue
    GROUP BY source, month
),

-- Step 2: Determine the top-performing traffic source
top_source AS (
    SELECT source, SUM(revenue) AS total_revenue
    FROM daily_revenue
    GROUP BY source
    ORDER BY total_revenue DESC
    LIMIT 1
),

-- Step 3: Calculate maximum revenues for the top-performing traffic source
max_revenues AS (
    (
      SELECT
        'Daily' AS time_type,
        date AS time,
        source,
        MAX(revenue) AS max_revenue
      FROM daily_revenue
      WHERE source = (SELECT source FROM top_source)
      GROUP BY source, date
      ORDER BY max_revenue DESC
      LIMIT 1
    )

    UNION ALL

    (
      SELECT
        'Weekly' AS time_type,
        week AS time,
        source,
        MAX(revenue) AS max_revenue
      FROM weekly_revenue
      WHERE source = (SELECT source FROM top_source)
      GROUP BY source, week
      ORDER BY max_revenue DESC
      LIMIT 1
    )

    UNION ALL

    (
      SELECT
          'Monthly' AS time_type,
          month AS time,
          source,
          MAX(revenue) AS max_revenue
      FROM monthly_revenue
      WHERE source = (SELECT source FROM top_source)
      GROUP BY source, month
      ORDER BY max_revenue DESC
      LIMIT 1
    )
)

-- Step 4: Select final results
SELECT
    time_type,
    time,
    source,
    max_revenue
FROM max_revenues
ORDER BY time_type, time;
