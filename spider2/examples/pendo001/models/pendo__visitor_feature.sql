with feature_event as (

    select *
    from {{ ref('pendo__feature_event') }}
),

calculate_metrics as (

    select
        visitor_id,
        feature_id,
        feature_name,
        product_area_id,
        product_area_name,
        min(occurred_at) as first_click_at,
        max(occurred_at) as last_click_at,
        sum(num_events) as sum_clicks,
        count(*) as count_click_events,
        sum(num_minutes) as sum_minutes,
        count(distinct {{ dbt.date_trunc('day', 'occurred_at') }} ) as count_active_days

    from feature_event
    {{ dbt_utils.group_by(n=5) }}
),

final as (

    select
        visitor_id,
        feature_id,
        feature_name,
        product_area_id,
        product_area_name,
        first_click_at,
        last_click_at,
        sum_clicks,
        sum_minutes,
        round(sum_minutes / nullif(count_active_days,0) , 3) as avg_daily_minutes,
        count_active_days,
        count_click_events

    from calculate_metrics
)

select *
from final