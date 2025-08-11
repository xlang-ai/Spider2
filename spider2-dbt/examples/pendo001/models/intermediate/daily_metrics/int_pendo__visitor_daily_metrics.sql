with events as (

    select 
        *,
        cast( {{ dbt.date_trunc('day', 'occurred_at') }} as date) as occurred_on

    from {{ var('event') }}
),

feature_event as (

    select 
        *,
        cast( {{ dbt.date_trunc('day', 'occurred_at') }} as date) as occurred_on

    from {{ var('feature_event') }}
),

page_event as (

    select 
        *,
        cast( {{ dbt.date_trunc('day', 'occurred_at') }} as date) as occurred_on

    from {{ var('page_event') }}
),

daily_event_metrics as (

    select 
        occurred_on,
        visitor_id,
        sum(num_minutes) as sum_minutes,
        sum(num_events) as sum_events,
        count(*) as count_event_records

    from events
    group by 1,2
),

daily_feature_metrics as (

    select 
        occurred_on,
        visitor_id,
        count(distinct feature_id) as count_features_clicked

    from feature_event
    group by  1,2
),

daily_page_metrics as (

    select 
        occurred_on,
        visitor_id,
        count(distinct page_id) as count_pages_viewed
        
    from page_event
    group by  1,2
),

daily_metric_join as (

    select 
        daily_event_metrics.*,
        coalesce(daily_page_metrics.count_pages_viewed, 0) as count_pages_viewed,
        coalesce(daily_feature_metrics.count_features_clicked, 0) as count_features_clicked
        
    from daily_event_metrics
    -- this should include tagged and untagged events so we can left join with specific event tables
    left join daily_page_metrics
        on daily_event_metrics.occurred_on = daily_page_metrics.occurred_on
        and daily_event_metrics.visitor_id = daily_page_metrics.visitor_id

    left join daily_feature_metrics
        on daily_event_metrics.occurred_on = daily_feature_metrics.occurred_on
        and daily_event_metrics.visitor_id = daily_feature_metrics.visitor_id
)

select *
from daily_metric_join