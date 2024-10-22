with device_report as (

    select *
    from {{ ref('google_play__device_report') }}
),

adapter as (

    select 
        source_relation,
        date_day,
        'google_play' as app_platform,
        package_name as app_name,
        device,
        device_uninstalls as deletions,
        device_installs as downloads
    from device_report
)

select * 
from adapter