with overview_report as (

    select *
    from {{ ref('apple_store__overview_report') }}
),

subsetted as (

    select 
        source_relation,
        date_day,
        'apple_store' as app_platform,
        app_name, 
        total_downloads as downloads,
        deletions,
        page_views,
        crashes
    from overview_report
)

select * 
from subsetted