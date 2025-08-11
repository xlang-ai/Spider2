with spine as (

    select *
    from {{ ref('int_pendo__calendar_spine') }}
),

daily_metrics as (

    select *
    from {{ ref('int_pendo__visitor_daily_metrics') }}
),

-- not brining pendo__visitor in because the default columns aren't super helpful and one can easily bring them in?
-- could also do what we do in the _event tables 
visitor_timeline as (

    select
        visitor_id,
        min(occurred_on) as first_event_on

    from daily_metrics
    group by 1
),

visitor_spine as (

    select 
        spine.date_day,
        visitor_timeline.visitor_id
    
    from spine 
    join visitor_timeline
        on spine.date_day >= visitor_timeline.first_event_on
        and spine.date_day <= cast( {{ dbt.current_timestamp_backcompat() }} as date)

),

final as (

    select
        visitor_spine.date_day,
        visitor_spine.visitor_id,
        daily_metrics.sum_minutes,
        daily_metrics.sum_events,
        daily_metrics.count_event_records,
        daily_metrics.count_pages_viewed,
        daily_metrics.count_features_clicked

    from visitor_spine
    left join daily_metrics
        on visitor_spine.date_day = daily_metrics.occurred_on
        and visitor_spine.visitor_id = daily_metrics.visitor_id
)

select *
from final