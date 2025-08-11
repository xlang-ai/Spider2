WITH base_table AS (
  SELECT
    event_name,
    event_date,
    event_timestamp,
    user_pseudo_id,
    user_id,
    device,
    geo,
    traffic_source,
    event_params,
    user_properties
  FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE
    _table_suffix = '20210102'
  AND event_name IN ('page_view')
)
, unnested_events AS (
-- unnests event parameters to get to relevant keys and values
  SELECT
    event_date AS date,
    event_timestamp AS event_timestamp_microseconds,
    user_pseudo_id,
    MAX(CASE WHEN c.key = 'ga_session_id' THEN c.value.int_value END) AS visitID,
    MAX(CASE WHEN c.key = 'ga_session_number' THEN c.value.int_value END) AS visitNumber,
    MAX(CASE WHEN c.key = 'page_title' THEN c.value.string_value END) AS page_title,
    MAX(CASE WHEN c.key = 'page_location' THEN c.value.string_value END) AS page_location
  FROM 
    base_table,
    UNNEST (event_params) c
  GROUP BY 1,2,3
)

, unnested_events_categorised AS (
-- categorizing Page Titles into PDPs and PLPs
  SELECT
  *,
  CASE WHEN ARRAY_LENGTH(SPLIT(page_location, '/')) >= 5 
            AND
            CONTAINS_SUBSTR(ARRAY_REVERSE(SPLIT(page_location, '/'))[SAFE_OFFSET(0)], '+')
            AND (LOWER(SPLIT(page_location, '/')[SAFE_OFFSET(4)]) IN 
                                        ('accessories','apparel','brands','campus+collection','drinkware',
                                          'electronics','google+redesign',
                                          'lifestyle','nest','new+2015+logo','notebooks+journals',
                                          'office','shop+by+brand','small+goods','stationery','wearables'
                                          )
                  OR
                  LOWER(SPLIT(page_location, '/')[SAFE_OFFSET(3)]) IN 
                                        ('accessories','apparel','brands','campus+collection','drinkware',
                                          'electronics','google+redesign',
                                          'lifestyle','nest','new+2015+logo','notebooks+journals',
                                          'office','shop+by+brand','small+goods','stationery','wearables'
                                          )
            )
            THEN 'PDP'
            WHEN NOT(CONTAINS_SUBSTR(ARRAY_REVERSE(SPLIT(page_location, '/'))[SAFE_OFFSET(0)], '+'))
            AND (LOWER(SPLIT(page_location, '/')[SAFE_OFFSET(4)]) IN 
                                        ('accessories','apparel','brands','campus+collection','drinkware',
                                          'electronics','google+redesign',
                                          'lifestyle','nest','new+2015+logo','notebooks+journals',
                                          'office','shop+by+brand','small+goods','stationery','wearables'
                                          )
                  OR 
                  LOWER(SPLIT(page_location, '/')[SAFE_OFFSET(3)]) IN 
                                          ('accessories','apparel','brands','campus+collection','drinkware',
                                            'electronics','google+redesign',
                                            'lifestyle','nest','new+2015+logo','notebooks+journals',
                                            'office','shop+by+brand','small+goods','stationery','wearables'
                                            )
            )
            THEN 'PLP'
        ELSE page_title
        END AS page_title_adjusted 

  FROM 
    unnested_events
)


, ranked_screens AS (
  SELECT
    *,
    LAG(page_title_adjusted,1) OVER (PARTITION BY  user_pseudo_id, visitID ORDER BY event_timestamp_microseconds ASC) previous_page,
    LEAD(page_title_adjusted,1) OVER (PARTITION BY  user_pseudo_id, visitID ORDER BY event_timestamp_microseconds ASC)  next_page
  FROM 
    unnested_events_categorised

)

,PLPtoPDPTransitions AS (
  SELECT
    user_pseudo_id,
    visitID
  FROM
    ranked_screens
  WHERE
    page_title_adjusted = 'PLP' AND next_page = 'PDP'
)

,TotalPLPViews AS (
  SELECT
    COUNT(*) AS total_plp_views
  FROM
    ranked_screens
  WHERE
    page_title_adjusted = 'PLP'
)

,TotalTransitions AS (
  SELECT
    COUNT(*) AS total_transitions
  FROM
    PLPtoPDPTransitions
)

SELECT
  (total_transitions * 100.0) / total_plp_views AS percentage
FROM
  TotalTransitions, TotalPLPViews;