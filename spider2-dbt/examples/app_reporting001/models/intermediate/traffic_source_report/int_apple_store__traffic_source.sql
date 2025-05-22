with traffic_source_report as (

    select *
    from {{ ref('apple_store__source_type_report') }}
),

subsetted as (

    select 
        source_relation,
        date_day,
        'apple_store' as app_platform,
        app_name, 
        source_type as traffic_source_type,
        sum(total_downloads) as downloads,
        sum(page_views) as page_views
    from traffic_source_report
    {{ dbt_utils.group_by(5) }}
)

select * 
from subsetted