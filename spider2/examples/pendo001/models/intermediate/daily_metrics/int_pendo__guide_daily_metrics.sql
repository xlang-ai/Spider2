with guide_event as (

    select 
        *,
        cast( {{ dbt.date_trunc('day', 'occurred_at') }} as date) as occurred_on

    from {{ ref('pendo__guide_event') }}
),

first_time_metrics as (
    
    select 
        *,
        -- get the first time this visitor/account has viewed this page
        min(occurred_on) over (partition by visitor_id, guide_id) as visitor_first_event_on,
        min(occurred_on) over (partition by account_id, guide_id) as account_first_event_on


    from guide_event
),

daily_metrics as (

    select
        occurred_on,
        guide_id,
        count(distinct visitor_id) as count_visitors,
        count(distinct account_id) as count_accounts,
        count(*) as count_guide_events,
        count(distinct case when occurred_on = visitor_first_event_on then visitor_id end) as count_first_time_visitors,
        count(distinct case when occurred_on = account_first_event_on then visitor_id end) as count_first_time_accounts,

        
    from first_time_metrics
    group by 1,2
)

select *
from daily_metrics