WITH
  UserInfo AS (
    SELECT
      user_pseudo_id,
      COUNTIF(event_name = 'page_view') AS page_view_count,
      COUNTIF(event_name IN ('in_app_purchase', 'purchase')) AS purchase_event_count
    FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
    WHERE _TABLE_SUFFIX BETWEEN '20201201' AND '20201231'
    GROUP BY 1
  ),
  Averages AS (
    SELECT
      (purchase_event_count > 0) AS purchaser,
      COUNT(*) AS user_count,
      SUM(page_view_count) AS total_page_views,
      SUM(page_view_count) / COUNT(*) AS avg_page_views
    FROM UserInfo
    GROUP BY 1
  )

SELECT
  MAX(CASE WHEN purchaser THEN avg_page_views ELSE 0 END) -
  MAX(CASE WHEN NOT purchaser THEN avg_page_views ELSE 0 END) AS avg_page_views_difference
FROM Averages;