with unioned as (

    {{ dbt_utils.union_relations(relations=[ref('int_apple_store__country'), ref('int_google_play__country')]) }}
),

final as (

    select
        source_relation,
        date_day,
        app_platform,
        app_name, 
        country_long,
        country_short,
        region,
        sub_region,
        downloads,
        deletions,
        page_views
    from unioned
)

select * 
from final