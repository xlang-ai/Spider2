with base as (

    select *
    from {{ ref('stg_google_play__store_performance_country_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_google_play__store_performance_country_tmp')),
                staging_columns=get_stats_store_performance_country_columns()
            )
        }}

    
        {{ fivetran_utils.source_relation(
            union_schema_variable='google_play_union_schemas', 
            union_database_variable='google_play_union_databases') 
        }}

    from base
),

final as (

    select
        cast(source_relation as {{ dbt.type_string() }}) as source_relation,
        cast(date as date) as date_day,
        cast(country_region as {{ dbt.type_string() }}) as country_region,
        cast(package_name as {{ dbt.type_string() }}) as package_name,
        sum(cast(store_listing_acquisitions as {{ dbt.type_bigint() }})) as store_listing_acquisitions,
        avg(store_listing_conversion_rate) as store_listing_conversion_rate,
        sum(cast(store_listing_visitors as {{ dbt.type_bigint() }})) as store_listing_visitors
    from fields
    {{ dbt_utils.group_by(4) }}
)

select *
from final
