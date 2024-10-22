with spine as (

    select *
    from {{ ref('int_pendo__calendar_spine') }}
),

daily_metrics as (

    select *
    from {{ ref('int_pendo__feature_daily_metrics') }}
),

feature as (

    select 
        *,
        cast( {{ dbt.date_trunc('day', 'created_at') }} as date) as created_on,
        cast( {{ dbt.date_trunc('day', 'last_click_at') }} as date) as last_click_on

    from {{ ref('pendo__feature') }}
),

feature_spine as (

    select 
        spine.date_day,
        feature.feature_id,
        feature.feature_name,
        feature.group_id, -- product_area ID
        feature.product_area_name,
        feature.page_id,
        feature.page_name
    
    from spine 
    join feature
        on spine.date_day >= feature.created_on
        and spine.date_day <= cast( {{ ['feature.valid_through', 'feature.last_click_on'] | max }} as date) -- or should this just go up to today?

),

final as (

    select
        feature_spine.date_day,
        feature_spine.feature_id,
        feature_spine.feature_name,
        feature_spine.group_id,
        feature_spine.product_area_name,
        feature_spine.page_id,
        feature_spine.page_name,

        coalesce(daily_metrics.sum_clicks, 0) as sum_clicks,
        coalesce(daily_metrics.count_visitors, 0) as count_visitors,
        coalesce(daily_metrics.count_accounts, 0) as count_accounts,
        coalesce(daily_metrics.count_first_time_visitors, 0) as count_first_time_visitors,
        coalesce(daily_metrics.count_first_time_accounts, 0) as count_first_time_accounts,
        coalesce(daily_metrics.count_return_visitors, 0) as count_return_visitors,
        coalesce(daily_metrics.count_return_accounts, 0) as count_return_accounts,
        coalesce(daily_metrics.avg_daily_minutes_per_visitor, 0) as avg_daily_minutes_per_visitor,
        coalesce(daily_metrics.avg_daily_clicks_per_visitor, 0) as avg_daily_clicks_per_visitor,
        coalesce(daily_metrics.percent_of_daily_feature_clicks, 0) as percent_of_daily_feature_clicks,
        coalesce(daily_metrics.percent_of_daily_feature_visitors, 0) as percent_of_daily_feature_visitors,
        coalesce(daily_metrics.percent_of_daily_feature_accounts, 0) as percent_of_daily_feature_accounts,
        coalesce(daily_metrics.count_click_events, 0) as count_click_events

    from feature_spine
    left join daily_metrics
        on feature_spine.date_day = daily_metrics.occurred_on
        and feature_spine.feature_id = daily_metrics.feature_id
)

select *
from final