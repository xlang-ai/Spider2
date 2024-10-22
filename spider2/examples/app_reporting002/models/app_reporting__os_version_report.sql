with unioned as (

    {{ dbt_utils.union_relations(relations=[ref('int_apple_store__os_version'), ref('int_google_play__os_version')]) }}
),

final as (

    select 
        source_relation,
        date_day,
        app_platform,
        app_name, 
        os_version,
        downloads,
        deletions,
        crashes
    from unioned
)

select * 
from final