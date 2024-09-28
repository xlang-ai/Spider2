SELECT
    creative_page_url,
    PARSE_TIMESTAMP('%Y-%m-%d', first_shown) AS first_shown,
    PARSE_TIMESTAMP('%Y-%m-%d', last_shown) AS last_shown,
    disapproval[0].removal_reason AS removal_reason,
    disapproval[0].violation_category AS violation_category,
    times_shown_lower_bound AS times_shown_lower,
    times_shown_upper_bound AS times_shown_upper
FROM
    `bigquery-public-data.google_ads_transparency_center.removed_creative_stats`,
    UNNEST(region_stats)
WHERE
    region_code = 'HR' AND
    times_shown_availability_date IS NULL AND
    times_shown_lower_bound > 10000 AND
    times_shown_upper_bound < 25000 AND
    (audience_selection_approach_info.demographic_info != 'CRITERIA_UNUSED' OR
     audience_selection_approach_info.geo_location != 'CRITERIA_UNUSED' OR
     audience_selection_approach_info.contextual_signals != 'CRITERIA_UNUSED' OR
     audience_selection_approach_info.customer_lists != 'CRITERIA_UNUSED' OR
     audience_selection_approach_info.topics_of_interest != 'CRITERIA_UNUSED')
ORDER BY
    last_shown DESC
LIMIT 5