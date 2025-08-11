SELECT
    "creative_page_url",
    TO_TIMESTAMP(GET("region_stat".value, 'first_shown')) AS "first_shown",
    TO_TIMESTAMP(GET("region_stat".value, 'last_shown')) AS "last_shown",
    REPLACE(REPLACE("disapproval"[0]."removal_reason", '""', '"'), '"', '') AS "removal_reason", 
    REPLACE(REPLACE("disapproval"[0]."violation_category", '""', '"'), '"', '') AS "violation_category",
    GET("region_stat".value, 'times_shown_lower_bound') AS "times_shown_lower",
    GET("region_stat".value, 'times_shown_upper_bound') AS "times_shown_upper"
FROM
    "GOOGLE_ADS"."GOOGLE_ADS_TRANSPARENCY_CENTER"."REMOVED_CREATIVE_STATS",
    LATERAL FLATTEN(input => "region_stats") AS "region_stat"
WHERE
    GET("region_stat".value, 'region_code') = 'HR' 
    AND GET("region_stat".value, 'times_shown_availability_date') IS NULL 
    AND GET("region_stat".value, 'times_shown_lower_bound') > 10000 
    AND GET("region_stat".value, 'times_shown_upper_bound') < 25000
    AND (
        GET("audience_selection_approach_info", 'demographic_info') != 'CRITERIA_UNUSED' 
        OR GET("audience_selection_approach_info", 'geo_location') != 'CRITERIA_UNUSED' 
        OR GET("audience_selection_approach_info", 'contextual_signals') != 'CRITERIA_UNUSED' 
        OR GET("audience_selection_approach_info", 'customer_lists') != 'CRITERIA_UNUSED' 
        OR GET("audience_selection_approach_info", 'topics_of_interest') != 'CRITERIA_UNUSED'
    )
ORDER BY
    "last_shown" DESC
LIMIT 5;
