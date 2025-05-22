{{config(enabled=snowplow.is_adapter('default'))}}

select
    user_custom_id,
    inferred_user_id,
    user_snowplow_domain_id,
    user_snowplow_crossdomain_id,
    app_id,
    first_page_url,
    marketing_medium,
    marketing_source,
    marketing_term,
    marketing_campaign,
    marketing_content,
    referer_url,
    to_timestamp(session_start) as session_start,
    to_timestamp(session_end) as session_end,
    session_id,
    time_engaged_in_s,
    session_index,
    first_test_add_col,
    last_test_add_col

from {{ ref('snowplow_sessions_expected') }}
