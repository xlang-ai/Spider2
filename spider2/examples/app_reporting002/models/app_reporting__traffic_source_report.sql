with unioned as (

    {{ dbt_utils.union_relations(relations=[ref('int_apple_store__traffic_source'), ref('int_google_play__traffic_source')]) }}
),

final as (

    select
        source_relation,
        date_day,
        app_platform,
        app_name,
        traffic_source_type,
        downloads,
        page_views
    from unioned
)

select * 
from final