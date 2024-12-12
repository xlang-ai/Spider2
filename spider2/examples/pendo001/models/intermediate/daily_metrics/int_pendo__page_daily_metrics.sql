with page_event as (

    select 
        *,
        cast( {{ dbt.date_trunc('day', 'occurred_at') }} as date) as occurred_on

    from {{ ref('pendo__page_event') }}
),

first_time_metrics as (
    
    select 
        *,
        -- get the first time this visitor/account has viewed this page
        min(occurred_on) over (partition by visitor_id, page_id) as visitor_first_event_on,
        min(occurred_on) over (partition by account_id, page_id) as account_first_event_on

    from page_event
),

daily_metrics as (

    select
        occurred_on,
        page_id,
        sum(num_events) as sum_pageviews,
        count(*) as count_pageview_events,
        count(distinct visitor_id) as count_visitors,
        count(distinct account_id) as count_accounts,
        count(distinct case when occurred_on = visitor_first_event_on then visitor_id end) as count_first_time_visitors,
        count(distinct case when occurred_on = account_first_event_on then account_id end) as count_first_time_accounts,
        sum(num_minutes) as sum_minutes
        
    from first_time_metrics
    group by 1,2
),

total_page_metrics as (

    select
        *,
        sum(sum_pageviews) over (partition by occurred_on) as total_pageviews,
        sum(count_visitors) over (partition by occurred_on) as total_page_visitors,
        sum(count_accounts) over (partition by occurred_on) as total_page_accounts

    from daily_metrics
),

final as (

    select 
        occurred_on,
        page_id,
        sum_pageviews,
        count_pageview_events,
        count_visitors,
        count_accounts,
        count_first_time_visitors,
        count_first_time_accounts,
        count_visitors - count_first_time_visitors as count_return_visitors,
        count_accounts - count_first_time_accounts as count_return_accounts,
        round(sum_minutes / nullif(count_visitors,0) , 3) as avg_daily_minutes_per_visitor,
        round(sum_pageviews / nullif(count_visitors,0) , 3) as avg_daily_pageviews_per_visitor,
        round(100.0 * sum_pageviews / nullif(total_pageviews,0) , 3) as percent_of_daily_pageviews,
        round(100.0 * count_visitors / nullif(total_page_visitors,0) , 3) as percent_of_daily_page_visitors,
        round(100.0 * count_accounts / nullif(total_page_accounts,0) , 3) as percent_of_daily_page_accounts
    
    from total_page_metrics
)

select *
from final