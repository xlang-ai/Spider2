with feature_event as (

    select *
    from {{ ref('pendo__feature_event') }}
),

calculate_metrics as (

    select
        feature_id,
        count(distinct visitor_id) as count_visitors,
        count(distinct account_id) as count_accounts,
        sum(num_events) as sum_clicks,
        count(*) as count_click_events,
        min(occurred_at) as first_click_at,
        max(occurred_at) as last_click_at,
        sum(num_minutes) / nullif(count(distinct visitor_id),0) as avg_visitor_minutes,
        sum(num_events) / nullif(count(distinct visitor_id),0) as avg_visitor_events

    from feature_event
    group by 1
),

feature_info as (

    select *
    from {{ ref('int_pendo__feature_info') }}

),

final as (

    select 
        feature_info.*,
        coalesce(calculate_metrics.count_visitors, 0) as count_visitors,
        coalesce(calculate_metrics.count_accounts, 0) as count_accounts,
        coalesce(calculate_metrics.sum_clicks, 0) as sum_clicks,
        coalesce(calculate_metrics.count_click_events, 0) as count_click_events,
        calculate_metrics.first_click_at,
        calculate_metrics.last_click_at,
        coalesce(round(calculate_metrics.avg_visitor_minutes, 3), 0) as avg_visitor_minutes,
        coalesce(round(calculate_metrics.avg_visitor_events, 3), 0) as avg_visitor_events

    from feature_info 
    left join calculate_metrics 
        on feature_info.feature_id = calculate_metrics.feature_id
)

select *
from final