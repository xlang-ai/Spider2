with app_version_report as (

    select *
    from {{ ref('google_play__app_version_report') }}
),

adapter as (

    select 
        source_relation,
        date_day,
        'google_play' as app_platform,
        package_name as app_name,
        cast(app_version_code as {{ dbt.type_string() }}) as app_version,
        device_uninstalls as deletions,
        crashes
    from app_version_report
)

select * 
from adapter