SELECT
    creative_page_url,
FROM `bigquery-public-data.google_ads_transparency_center.creative_stats`,
    UNNEST(region_stats)
    
WHERE
    region_code = 'HR' AND
    times_shown_availability_date IS NULL AND
    audience_selection_approach_info.demographic_info != 'CRITERIA_UNUSED' AND
    audience_selection_approach_info.geo_location != 'CRITERIA_UNUSED' AND
    audience_selection_approach_info.contextual_signals != 'CRITERIA_UNUSED' AND
    audience_selection_approach_info.customer_lists != 'CRITERIA_UNUSED' AND
    audience_selection_approach_info.topics_of_interest != 'CRITERIA_UNUSED' AND
    
    advertiser_verification_status = 'VERIFIED' AND
    advertiser_location = 'CY' AND
    ad_format_type = 'IMAGE' AND
    topic = 'Health' AND
    
    PARSE_TIMESTAMP('%Y-%m-%d', first_shown) > TIMESTAMP('2023-01-01') AND
    PARSE_TIMESTAMP('%Y-%m-%d', last_shown) < TIMESTAMP('2024-01-01')
ORDER BY times_shown_upper_bound DESC
LIMIT 1
