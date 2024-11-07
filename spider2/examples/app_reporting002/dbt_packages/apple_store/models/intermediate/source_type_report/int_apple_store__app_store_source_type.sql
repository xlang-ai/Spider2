with base as (

    select * 
    from {{ var('app_store_device') }}
),

aggregated as (

    select 
        source_relation,
        date_day,
        app_id,
        source_type,
        sum(impressions) as impressions,
        sum(page_views) as page_views
    from base 
    {{ dbt_utils.group_by(4) }}
)

select * 
from aggregated