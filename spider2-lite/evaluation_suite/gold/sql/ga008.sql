WITH
  UserInfo AS (
    SELECT
      user_pseudo_id,
      PARSE_DATE('%Y%m%d', event_date) AS event_date,
      COUNTIF(event_name = 'page_view') AS page_view_count,
      COUNTIF(event_name = 'purchase') AS purchase_event_count
    FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
    WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20201130'
    GROUP BY 1, 2
  )
SELECT
  event_date,
  SUM(page_view_count) / COUNT(*) AS avg_page_views,
  SUM(page_view_count)
FROM UserInfo
WHERE purchase_event_count > 0
GROUP BY event_date
ORDER BY event_date;