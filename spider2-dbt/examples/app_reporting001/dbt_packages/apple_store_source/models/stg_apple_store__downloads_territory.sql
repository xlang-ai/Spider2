with base as (

    select * 
    from {{ ref('stg_apple_store__downloads_territory_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_apple_store__downloads_territory_tmp')),
                staging_columns=get_downloads_territory_columns()
            )
        }}
        
    
        {{ fivetran_utils.source_relation(
            union_schema_variable='apple_store_union_schemas', 
            union_database_variable='apple_store_union_databases') 
        }}

    from base
),

final as (

    select
        cast(source_relation as {{ dbt.type_string() }}) as source_relation, 
        cast(date as date) as date_day,
        cast(app_id as {{ dbt.type_bigint() }}) as app_id,
        cast(source_type as {{ dbt.type_string() }}) as source_type,
        cast(territory as {{ dbt.type_string() }}) as territory,
        cast(first_time_downloads as {{ dbt.type_bigint() }}) as first_time_downloads,
        cast(redownloads as {{ dbt.type_bigint() }}) as redownloads,
        cast(total_downloads as {{ dbt.type_bigint() }}) as total_downloads
    from fields
)

select * 
from final
