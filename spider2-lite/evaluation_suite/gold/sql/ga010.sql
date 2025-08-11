WITH prep AS (
  SELECT
    user_pseudo_id,
    (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS session_id,
    ARRAY_AGG((SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'source') IGNORE NULLS 
              ORDER BY event_timestamp)[SAFE_OFFSET(0)] AS source,
    ARRAY_AGG((SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'medium') IGNORE NULLS 
              ORDER BY event_timestamp)[SAFE_OFFSET(0)] AS medium,
    ARRAY_AGG((SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'campaign') IGNORE NULLS 
              ORDER BY event_timestamp)[SAFE_OFFSET(0)] AS campaign
  FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE
    _TABLE_SUFFIX BETWEEN '20201201' AND '20201231'
  GROUP BY
    user_pseudo_id,
    session_id
)
SELECT
  -- session default channel grouping (dimension | the channel group associated with a session) 
  CASE 
    WHEN source = '(direct)' AND (medium IN ('(not set)','(none)')) THEN 'Direct'
    WHEN REGEXP_CONTAINS(campaign, 'cross-network') THEN 'Cross-network'
    WHEN (REGEXP_CONTAINS(source,'alibaba|amazon|google shopping|shopify|etsy|ebay|stripe|walmart')
        OR REGEXP_CONTAINS(campaign, '^(.*(([^a-df-z]|^)shop|shopping).*)$'))
        AND REGEXP_CONTAINS(medium, '^(.*cp.*|ppc|paid.*)$') THEN 'Paid Shopping'
    WHEN REGEXP_CONTAINS(source,'baidu|bing|duckduckgo|ecosia|google|yahoo|yandex')
        AND REGEXP_CONTAINS(medium,'^(.*cp.*|ppc|paid.*)$') THEN 'Paid Search'
    WHEN REGEXP_CONTAINS(source,'badoo|facebook|fb|instagram|linkedin|pinterest|tiktok|twitter|whatsapp')
        AND REGEXP_CONTAINS(medium,'^(.*cp.*|ppc|paid.*)$') THEN 'Paid Social'
    WHEN REGEXP_CONTAINS(source,'dailymotion|disneyplus|netflix|youtube|vimeo|twitch|vimeo|youtube')
        AND REGEXP_CONTAINS(medium,'^(.*cp.*|ppc|paid.*)$') THEN 'Paid Video'
    WHEN medium IN ('display', 'banner', 'expandable', 'interstitial', 'cpm') THEN 'Display'
    WHEN REGEXP_CONTAINS(source,'alibaba|amazon|google shopping|shopify|etsy|ebay|stripe|walmart')
        OR REGEXP_CONTAINS(campaign, '^(.*(([^a-df-z]|^)shop|shopping).*)$') THEN 'Organic Shopping'
    WHEN REGEXP_CONTAINS(source,'badoo|facebook|fb|instagram|linkedin|pinterest|tiktok|twitter|whatsapp')
        OR medium IN ('social','social-network','social-media','sm','social network','social media') THEN 'Organic Social'
    WHEN REGEXP_CONTAINS(source,'dailymotion|disneyplus|netflix|youtube|vimeo|twitch|vimeo|youtube')
        OR REGEXP_CONTAINS(medium,'^(.*video.*)$') THEN 'Organic Video'
    WHEN REGEXP_CONTAINS(source,'baidu|bing|duckduckgo|ecosia|google|yahoo|yandex')
        OR medium = 'organic' THEN 'Organic Search'
    WHEN REGEXP_CONTAINS(source,'email|e-mail|e_mail|e mail')
        OR REGEXP_CONTAINS(medium,'email|e-mail|e_mail|e mail') THEN 'Email'
    WHEN medium = 'affiliate' THEN 'Affiliates'
    WHEN medium = 'referral' THEN 'Referral'
    WHEN medium = 'audio' THEN 'Audio'
    WHEN medium = 'sms' THEN 'SMS'
    WHEN medium LIKE '%push'
        OR REGEXP_CONTAINS(medium,'mobile|notification') THEN 'Mobile Push Notifications'
    ELSE 'Unassigned' 
  END AS channel_grouping_session
FROM
  prep
GROUP BY
  channel_grouping_session
ORDER BY
  COUNT(DISTINCT CONCAT(user_pseudo_id, session_id)) DESC
LIMIT 1 OFFSET 3