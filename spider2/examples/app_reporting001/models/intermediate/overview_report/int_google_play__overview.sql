with overview_report as (

    select *
    from {{ ref('google_play__overview_report') }}
),

adapter as (

    select 
        source_relation,
        date_day,
        'google_play' as app_platform,
        package_name as app_name,
        device_uninstalls as deletions,
        device_installs as downloads,
        store_listing_visitors as page_views,
        crashes
    from overview_report
)

select * 
from adapter