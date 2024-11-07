with os_version_report as (

    select *
    from {{ ref('apple_store__platform_version_report') }}
),

subsetted as (

    select 
        source_relation,
        date_day,
        'apple_store' as app_platform,
        app_name, 
        platform_version as os_version,
        sum(total_downloads) as downloads,
        sum(deletions) as deletions,
        sum(crashes) as crashes
    from os_version_report
    {{ dbt_utils.group_by(5) }}
)

select * 
from subsetted