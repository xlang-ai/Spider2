with traffic_source_report as (

    select *
    from {{ ref('stg_google_play__store_performance_source') }}
),

adapter as (

    select 
        source_relation,
        date_day,
        'google_play' as app_platform,
        package_name as app_name,
        traffic_source as traffic_source_type,
        sum(coalesce(store_listing_acquisitions, 0)) as downloads,
        sum(coalesce(store_listing_visitors, 0)) as page_views
    from traffic_source_report
    {{ dbt_utils.group_by(5) }}
)

select * 
from adapter