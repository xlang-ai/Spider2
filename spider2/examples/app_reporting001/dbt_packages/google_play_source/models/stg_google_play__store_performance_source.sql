with base as (

    select *
    from {{ ref('stg_google_play__store_performance_source_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_google_play__store_performance_source_tmp')),
                staging_columns=get_stats_store_performance_traffic_source_columns()
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
        cast(package_name as {{ dbt.type_string() }}) as package_name,
        traffic_source,
        search_term,
        utm_campaign,
        utm_source,
        cast(store_listing_acquisitions as {{ dbt.type_bigint() }}) as store_listing_acquisitions,
        store_listing_conversion_rate,
        cast(store_listing_visitors as {{ dbt.type_bigint() }}) as store_listing_visitors,
        -- make a surrogate key as the PK involves quite a few columns
        {{ dbt_utils.generate_surrogate_key(['source_relation', 'date', 'package_name', 'traffic_source', 'search_term', 'utm_campaign', 'utm_source']) }} as traffic_source_unique_key,
        _fivetran_synced
    from fields
)

select *
from final
