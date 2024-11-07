with device_report as (

    select *
    from {{ ref('apple_store__device_report') }}
),

subsetted as (

    select 
        source_relation,
        date_day,
        'apple_store' as app_platform,
        app_name, 
        device,
        sum(total_downloads) as downloads,
        sum(deletions) as deletions
    from device_report
    {{ dbt_utils.group_by(5) }}
)

select * 
from subsetted