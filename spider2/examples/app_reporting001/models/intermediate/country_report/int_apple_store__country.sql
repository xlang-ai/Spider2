with country_report as (

    select *
    from {{ ref('apple_store__territory_report') }}
),

subsetted as (

    select 
        source_relation,
        date_day,
        'apple_store' as app_platform,
        app_name, 
        territory_long as country_long,
        territory_short as country_short,
        region,
        sub_region,
        sum(total_downloads) as downloads,
        sum(deletions) as deletions,
        sum(page_views) as page_views
    from country_report
    {{ dbt_utils.group_by(8) }}
)

select * 
from subsetted