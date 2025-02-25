WITH PurchasingUsers AS (
    SELECT DISTINCT user_pseudo_id
    FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_202011*`
    WHERE event_name = 'purchase'
),
DailyPageViews AS (
    SELECT 
        FORMAT_DATE('%Y-%m-%d', PARSE_DATE('%Y%m%d', t1.event_date)) AS event_date,
        COUNT(CASE WHEN event_name = 'page_view' THEN 1 END) AS total_page_views,
        COUNT(DISTINCT CASE WHEN event_name = 'page_view' THEN t1.user_pseudo_id END) AS unique_users_with_page_view
    FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_202011*` t1
    INNER JOIN PurchasingUsers pu ON t1.user_pseudo_id = pu.user_pseudo_id
    WHERE t1.event_name = 'page_view'
    GROUP BY 1
)
SELECT 
    event_date,
    total_page_views,
    total_page_views / unique_users_with_page_view AS avg_page_views_per_user
FROM DailyPageViews
ORDER BY event_date