-- Query a specific date range. To query a specific date range from a BigQuery event export dataset, use the _TABLE_SUFFIX pseudo column in the WHERE clause of your query. For more info, view Filtering selected tables using _TABLE_SUFFIX. For example, the following query counts unique events by date and by event name for a specifc period of days and selected events:



SELECT
  event_date,
  event_name,
  COUNT(*) AS event_count
FROM
  -- Replace table name.
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE
  event_name IN ('page_view', 'session_start', 'purchase')
  -- Replace date range.
  AND _TABLE_SUFFIX BETWEEN '20201201' AND '20201202'
GROUP BY 1, 2;

