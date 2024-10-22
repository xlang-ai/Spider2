with unioned as (

    {{ dbt_utils.union_relations(relations=[ref('int_apple_store__device'), ref('int_google_play__device')]) }}
), 

final as (

    select
        source_relation,
        date_day,
        app_platform,
        app_name, 
        device,
        downloads,
        deletions
    from unioned
)

select * 
from final