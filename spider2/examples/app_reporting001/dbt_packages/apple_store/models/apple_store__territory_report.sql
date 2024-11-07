with app as (

    select * 
    from {{ var('app') }}
),

app_store_territory as (

    select *
    from {{ var('app_store_territory') }}
),

country_codes as (

    select * 
    from {{ var('apple_store_country_codes') }}
),

downloads_territory as (

    select *
    from {{ var('downloads_territory') }}
),

usage_territory as (

    select * 
    from {{ var('usage_territory') }}
),

reporting_grain as (

    select distinct
        source_relation,
        date_day,
        app_id,
        source_type,
        territory 
    from app_store_territory
),

joined as (

    select 
        reporting_grain.source_relation,
        reporting_grain.date_day,
        reporting_grain.app_id,
        app.app_name,
        reporting_grain.source_type,
        reporting_grain.territory as territory_long,
        coalesce(official_country_codes.country_code_alpha_2, alternative_country_codes.country_code_alpha_2) as territory_short,
        coalesce(official_country_codes.region, alternative_country_codes.region) as region,
        coalesce(official_country_codes.sub_region, alternative_country_codes.sub_region) as sub_region,
        coalesce(app_store_territory.impressions, 0) as impressions,
        coalesce(app_store_territory.impressions_unique_device, 0) as impressions_unique_device,
        coalesce(app_store_territory.page_views, 0) as page_views,
        coalesce(app_store_territory.page_views_unique_device, 0) as page_views_unique_device,
        coalesce(downloads_territory.first_time_downloads, 0) as first_time_downloads,
        coalesce(downloads_territory.redownloads, 0) as redownloads,
        coalesce(downloads_territory.total_downloads, 0) as total_downloads,
        coalesce(usage_territory.active_devices, 0) as active_devices,
        coalesce(usage_territory.active_devices_last_30_days, 0) as active_devices_last_30_days,
        coalesce(usage_territory.deletions, 0) as deletions,
        coalesce(usage_territory.installations, 0) as installations,
        coalesce(usage_territory.sessions, 0) as sessions
    from reporting_grain
    left join app 
        on reporting_grain.app_id = app.app_id
        and reporting_grain.source_relation = app.source_relation
    left join app_store_territory 
        on reporting_grain.date_day = app_store_territory.date_day
        and reporting_grain.source_relation = app_store_territory.source_relation
        and reporting_grain.app_id = app_store_territory.app_id 
        and reporting_grain.source_type = app_store_territory.source_type
        and reporting_grain.territory = app_store_territory.territory
    left join downloads_territory
        on reporting_grain.date_day = downloads_territory.date_day
        and reporting_grain.source_relation = downloads_territory.source_relation
        and reporting_grain.app_id = downloads_territory.app_id 
        and reporting_grain.source_type = downloads_territory.source_type
        and reporting_grain.territory = downloads_territory.territory
    left join usage_territory
        on reporting_grain.date_day = usage_territory.date_day
        and reporting_grain.source_relation = usage_territory.source_relation
        and reporting_grain.app_id = usage_territory.app_id 
        and reporting_grain.source_type = usage_territory.source_type
        and reporting_grain.territory = usage_territory.territory
    left join country_codes as official_country_codes
        on reporting_grain.territory = official_country_codes.country_name
    left join country_codes as alternative_country_codes
        on reporting_grain.territory = alternative_country_codes.alternative_country_name
)

select * 
from joined