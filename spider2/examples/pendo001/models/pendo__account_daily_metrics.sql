with spine as (

    select *
    from {{ ref('int_pendo__calendar_spine') }}
),

daily_metrics as (

    select *
    from {{ ref('int_pendo__account_daily_metrics') }}
),

-- not brining pendo__account in because the default columns aren't super helpful and one can easily bring them in?
-- could also do what we do in the _event tables 
account_timeline as (

    select 
        account_id,
        min(occurred_on) as first_event_on

    from daily_metrics
    group by 1
),

account_spine as (

    select 
        spine.date_day,
        account_timeline.account_id
    
    from spine 
    join account_timeline
        on spine.date_day >= account_timeline.first_event_on
        and spine.date_day <= cast( {{ dbt.current_timestamp_backcompat() }} as date)

),

final as (

    select
        account_spine.date_day,
        account_spine.account_id,
        daily_metrics.count_active_visitors,
        daily_metrics.sum_minutes,
        daily_metrics.sum_events,
        daily_metrics.count_event_records,
        daily_metrics.count_pages_viewed,
        daily_metrics.count_features_clicked,
        daily_metrics.count_page_viewing_visitors,
        daily_metrics.count_feature_clicking_visitors

    from account_spine
    left join daily_metrics
        on account_spine.date_day = daily_metrics.occurred_on
        and account_spine.account_id = daily_metrics.account_id
)

select *
from final