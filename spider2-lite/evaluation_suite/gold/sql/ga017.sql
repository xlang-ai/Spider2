WITH unnested_events AS (
  SELECT
    MAX(CASE WHEN event_params.key = 'page_location' THEN event_params.value.string_value END) AS page_location,
    user_pseudo_id,
    event_timestamp
  FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`,
    UNNEST(event_params) AS event_params
  WHERE
    _TABLE_SUFFIX BETWEEN '20210101' AND '20210131'
    AND event_name = 'page_view'
  GROUP BY user_pseudo_id,event_timestamp
),
temp AS (
    SELECT
    page_location,
    COUNT(*) AS event_count,
    COUNT(DISTINCT user_pseudo_id) AS users
    FROM
    unnested_events
    GROUP BY page_location
    ORDER BY event_count DESC
)

SELECT users 
FROM
temp
LIMIT 1