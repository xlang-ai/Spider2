WITH visitor_pageviews AS (
  SELECT
    FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d', date)) AS month,
    CASE WHEN totals.transactions > 0 THEN 'purchase' ELSE 'non_purchase' END AS purchase_status,
    fullVisitorId,
    SUM(totals.pageviews) AS total_pageviews
  FROM
    `bigquery-public-data.google_analytics_sample.ga_sessions_*`
  WHERE
    _TABLE_SUFFIX BETWEEN '20170601' AND '20170731'
    AND totals.pageviews IS NOT NULL
  GROUP BY
    month, purchase_status, fullVisitorId
),
avg_pageviews AS (
  SELECT
    month,
    purchase_status,
    AVG(total_pageviews) AS avg_pageviews_per_visitor
  FROM
    visitor_pageviews
  GROUP BY
    month, purchase_status
)
SELECT
  month,
  MAX(CASE WHEN purchase_status = 'purchase' THEN avg_pageviews_per_visitor END) AS avg_pageviews_purchase,
  MAX(CASE WHEN purchase_status = 'non_purchase' THEN avg_pageviews_per_visitor END) AS avg_pageviews_non_purchase
FROM
  avg_pageviews
GROUP BY
  month
ORDER BY
  month