with app as (

    select * 
    from {{ var('app') }}
),

app_store_source_type as (

    select *
    from {{ ref('int_apple_store__app_store_source_type') }}
),

downloads_source_type as (

    select *
    from {{ ref('int_apple_store__downloads_source_type') }}
),

usage_source_type as (

    select *
    from {{ ref('int_apple_store__usage_source_type') }}
),

reporting_grain as (

    select distinct
        source_relation,
        date_day,
        app_id,
        source_type
    from app_store_source_type
),

joined as (

    select 
        reporting_grain.source_relation,
        reporting_grain.date_day,
        reporting_grain.app_id, 
        app.app_name,
        reporting_grain.source_type,
        coalesce(app_store_source_type.impressions, 0) as impressions,
        coalesce(app_store_source_type.page_views, 0) as page_views,
        coalesce(downloads_source_type.first_time_downloads, 0) as first_time_downloads,
        coalesce(downloads_source_type.redownloads, 0) as redownloads,
        coalesce(downloads_source_type.total_downloads, 0) as total_downloads,
        coalesce(usage_source_type.active_devices, 0) as active_devices,
        coalesce(usage_source_type.deletions, 0) as deletions,
        coalesce(usage_source_type.installations, 0) as installations,
        coalesce(usage_source_type.sessions, 0) as sessions
    from reporting_grain
    left join app 
        on reporting_grain.app_id = app.app_id
        and reporting_grain.source_relation = app.source_relation
    left join app_store_source_type
        on reporting_grain.date_day = app_store_source_type.date_day
        and reporting_grain.source_relation = app_store_source_type.source_relation
        and reporting_grain.app_id = app_store_source_type.app_id 
        and reporting_grain.source_type = app_store_source_type.source_type
    left join downloads_source_type
        on reporting_grain.date_day = downloads_source_type.date_day
        and reporting_grain.source_relation = downloads_source_type.source_relation
        and reporting_grain.app_id = downloads_source_type.app_id 
        and reporting_grain.source_type = downloads_source_type.source_type
    left join usage_source_type
        on reporting_grain.date_day = usage_source_type.date_day
        and reporting_grain.source_relation = usage_source_type.source_relation
        and reporting_grain.app_id = usage_source_type.app_id 
        and reporting_grain.source_type = usage_source_type.source_type
)

select * 
from joined