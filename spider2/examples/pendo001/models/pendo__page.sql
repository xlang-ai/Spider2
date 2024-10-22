with page_event as (

    select *
    from {{ ref('pendo__page_event') }}
),

calculate_metrics as (

    select
        page_id,
        count(distinct visitor_id) as count_visitors,
        count(distinct account_id) as count_accounts,
        sum(num_events) as sum_pageviews,
        count(*) as count_pageview_events,
        min(occurred_at) as first_pageview_at,
        max(occurred_at) as last_pageview_at,
        sum(num_minutes) / nullif(count(distinct visitor_id),0) as avg_visitor_minutes,
        sum(num_events) / nullif(count(distinct visitor_id),0) as avg_visitor_pageviews

    from page_event
    group by 1
),

page_info as (

    select *
    from {{ ref('int_pendo__page_info') }}

),

final as (

    select 
        page_info.*,
        coalesce(calculate_metrics.count_visitors, 0) as count_visitors,
        coalesce(calculate_metrics.count_accounts, 0) as count_accounts,
        coalesce(calculate_metrics.sum_pageviews, 0) as sum_pageviews,
        coalesce(calculate_metrics.count_pageview_events, 0) as count_pageview_events,
        calculate_metrics.first_pageview_at,
        calculate_metrics.last_pageview_at,
        coalesce(round(calculate_metrics.avg_visitor_minutes, 3), 0) as avg_visitor_minutes,
        coalesce(round(calculate_metrics.avg_visitor_pageviews, 3), 0) as avg_visitor_pageviews

    from page_info 
    left join calculate_metrics 
        on page_info.page_id = calculate_metrics.page_id
)

select *
from final