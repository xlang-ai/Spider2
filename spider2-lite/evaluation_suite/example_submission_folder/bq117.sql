WITH base_info AS (
  SELECT
    episode_id, 
    CONCAT(CAST(EXTRACT(MONTH FROM MIN(event_begin_time)) AS STRING), "-", CAST(EXTRACT(year FROM MIN(event_begin_time)) AS STRING)) as episode_month,
    EXTRACT(MONTH FROM MIN(event_begin_time)) AS month,
    STRING_AGG(DISTINCT(cz_name) LIMIT 5) as counties, 
    STRING_AGG(DISTINCT(state)) as states, 
    STRING_AGG(DISTINCT(event_type) LIMIT 5) as event_types,
    SUM(damage_property)/1000000000 as damage_property_in_billions
  FROM
    `bigquery-public-data.noaa_historic_severe_storms.storms_*`
  WHERE
    _TABLE_SUFFIX BETWEEN CAST((EXTRACT(YEAR from CURRENT_DATE())-15) AS STRING) AND CAST(EXTRACT(YEAR from CURRENT_DATE()) AS STRING)
  GROUP BY
    episode_id
  ORDER BY
    damage_property_in_billions desc
  LIMIT 100
)

SELECT COUNT(*) AS month_count
FROM base_info
GROUP BY month
ORDER BY month_count DESC
LIMIT 1
