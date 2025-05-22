with unioned as (

    {{ dbt_utils.union_relations(relations=[ref('int_apple_store__overview'), ref('int_google_play__overview')]) }}
),

final as (

    select 
        source_relation,
        date_day,
        app_platform,
        app_name, 
        downloads,
        deletions,
        page_views,
        crashes
    from unioned
)

select * 
from final