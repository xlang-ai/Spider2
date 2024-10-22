with account as (

    select *
    from {{ ref('int_pendo__latest_account') }}

),

visitor_account as (

    select *
    from {{ ref('int_pendo__latest_visitor_account') }}
),

agg_visitors as (

    select 
        account_id,
        count(distinct visitor_id) as count_visitors

    from visitor_account
    group by 1
),

nps_ratings as (

    select * 
    from {{ ref('int_pendo__latest_nps_rating') }}
),

nps_metrics as (

    select
        account_id, 
        min(nps_rating) as min_nps_rating,
        max(nps_rating) as max_nps_rating,
        avg(nps_rating) as avg_nps_rating

    from nps_ratings
    group by 1
),

daily_metrics as (

    select *
    from {{ ref('int_pendo__account_daily_metrics') }}
),

calculate_metrics as (

    select
        account_id,
        sum(count_active_visitors) as count_active_visitors, -- all-time, not currently
        sum(count_page_viewing_visitors) as count_page_viewing_visitors,
        sum(count_feature_clicking_visitors) as count_feature_clicking_visitors,
        count(distinct occurred_on) as count_active_days,
        count(distinct {{ dbt.date_trunc('month', 'occurred_on') }} ) as count_active_months,
        sum(sum_minutes) as sum_minutes,
        sum(sum_events) as sum_events,
        sum(count_event_records) as count_event_records,
        sum(sum_minutes) / nullif(count(distinct occurred_on),0) as average_daily_minutes,
        sum(sum_events) / nullif(count(distinct occurred_on),0) as average_daily_events,
        min(occurred_on) as first_event_on,
        max(occurred_on) as last_event_on
        
    from daily_metrics
    group by 1
),

account_join as (

    select 
        account.*,
        coalesce(agg_visitors.count_visitors, 0) as count_associated_visitors,
        nps_metrics.min_nps_rating,
        nps_metrics.max_nps_rating,
        nps_metrics.avg_nps_rating,

        coalesce(calculate_metrics.count_active_visitors, 0) as count_active_visitors,
        coalesce(calculate_metrics.count_page_viewing_visitors, 0) as count_page_viewing_visitors,
        coalesce(calculate_metrics.count_feature_clicking_visitors, 0) as count_feature_clicking_visitors,
        coalesce(calculate_metrics.count_active_days, 0) as count_active_days,
        coalesce(calculate_metrics.count_active_months, 0) as count_active_months,
        coalesce(calculate_metrics.sum_minutes, 0) as sum_minutes,
        coalesce(calculate_metrics.sum_events, 0) as sum_events,
        coalesce(calculate_metrics.count_event_records, 0) as count_event_records,
        coalesce(calculate_metrics.average_daily_minutes, 0) as average_daily_minutes,
        coalesce(calculate_metrics.average_daily_events, 0) as average_daily_events,
        calculate_metrics.first_event_on,
        calculate_metrics.last_event_on

    from account
    left join agg_visitors 
        on account.account_id = agg_visitors.account_id
    left join nps_metrics
        on account.account_id = nps_metrics.account_id
    left join calculate_metrics
        on account.account_id = calculate_metrics.account_id
)

select *
from account_join