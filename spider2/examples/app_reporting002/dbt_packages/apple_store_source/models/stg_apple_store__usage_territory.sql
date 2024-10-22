with base as (

    select * 
    from {{ ref('stg_apple_store__usage_territory_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_apple_store__usage_territory_tmp')),
                staging_columns=get_usage_territory_columns()
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
        cast(active_devices as {{ dbt.type_bigint() }}) as active_devices,
        cast(active_devices_last_30_days as {{ dbt.type_bigint() }}) as active_devices_last_30_days,
        cast(deletions as {{ dbt.type_bigint() }}) as deletions,
        cast(installations as {{ dbt.type_bigint() }}) as installations,
        cast(sessions as {{ dbt.type_bigint() }}) as sessions
    from fields
)

select * 
from final
