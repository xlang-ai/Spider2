with store_performance as (

    select *
    from {{ var('stats_store_performance_country') }}
), 

store_performance_rollup as (

    select 
        source_relation,
        date_day,
        package_name,
        sum(store_listing_acquisitions) as store_listing_acquisitions,
        sum(store_listing_visitors) as store_listing_visitors
    from store_performance
    {{ dbt_utils.group_by(3) }}
),

store_performance_metrics as (

    select
        *,
        round(store_listing_acquisitions * 1.0 / nullif(store_listing_visitors, 0), 4) as store_listing_conversion_rate,
        sum(store_listing_acquisitions) over (partition by source_relation, package_name order by date_day asc rows between unbounded preceding and current row) as total_store_acquisitions,
        sum(store_listing_visitors) over (partition by source_relation, package_name order by date_day asc rows between unbounded preceding and current row) as total_store_visitors
    from store_performance_rollup
)

select *
from store_performance_metrics