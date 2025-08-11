with unioned as (

    {{ dbt_utils.union_relations(relations=[ref('int_apple_store__app_version'), ref('int_google_play__app_version')]) }}
), 

final as (

    select 
        source_relation,
        date_day,
        app_platform,
        app_name,
        app_version,
        deletions,
        crashes
    from unioned
)

select * 
from final