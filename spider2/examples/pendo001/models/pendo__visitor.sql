with visitor as (

    select *
    from {{ ref('int_pendo__latest_visitor') }}

),

visitor_account as (

    select *
    from {{ ref('int_pendo__latest_visitor_account') }}
),

agg_accounts as (

    select 
        visitor_id,
        count(*) as count_associated_accounts

    from visitor_account
    group by 1
),

nps_rating as (

    select * 
    from {{ ref('int_pendo__latest_nps_rating') }}
),

daily_metrics as (

    select *
    from {{ ref('int_pendo__visitor_daily_metrics') }}
),

calculate_metrics as (

    select
        visitor_id,
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

visitor_join as (

    select 
        visitor.*,
        agg_accounts.count_associated_accounts,
        nps_rating.nps_rating as latest_nps_rating,

        coalesce(calculate_metrics.count_active_days, 0) as count_active_days,
        coalesce(calculate_metrics.count_active_months, 0) as count_active_months,
        coalesce(calculate_metrics.sum_minutes, 0) as sum_minutes,
        coalesce(calculate_metrics.sum_events, 0) as sum_events,
        coalesce(calculate_metrics.count_event_records, 0) as count_event_records,
        coalesce(calculate_metrics.average_daily_minutes, 0) as average_daily_minutes,
        coalesce(calculate_metrics.average_daily_events, 0) as average_daily_events,
        calculate_metrics.first_event_on,
        calculate_metrics.last_event_on
        
    from visitor
    left join agg_accounts 
        on visitor.visitor_id = agg_accounts.visitor_id
    left join nps_rating
        on visitor.visitor_id = nps_rating.visitor_id
    left join calculate_metrics
        on visitor.visitor_id = calculate_metrics.visitor_id
)

select *
from visitor_join