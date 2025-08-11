with country_report as (

    select *
    from {{ ref('google_play__country_report') }}
),

adapter as (

    select 
        source_relation,
        date_day,
        'google_play' as app_platform,
        package_name as app_name,
        country_long,
        country_short,
        region,
        sub_region,
        device_uninstalls as deletions,
        device_installs as downloads,
        store_listing_visitors as page_views
    from country_report
)

select * 
from adapter