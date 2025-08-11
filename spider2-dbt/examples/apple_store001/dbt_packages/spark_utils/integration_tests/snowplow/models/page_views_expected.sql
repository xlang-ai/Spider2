{{config(enabled=snowplow.is_adapter('default'))}}

select

    user_custom_id,
    user_snowplow_domain_id,
    user_snowplow_crossdomain_id,
    session_id,
    session_index,
    page_view_id,
    to_timestamp(page_view_start) as page_view_start,
    to_timestamp(page_view_end) as page_view_end,
    time_engaged_in_s,
    horizontal_percentage_scrolled,
    vertical_percentage_scrolled,
    page_url,
    marketing_medium,
    marketing_source,
    marketing_term,
    marketing_content,
    marketing_campaign,
    test_add_col

from {{ ref('snowplow_page_views_expected') }}
