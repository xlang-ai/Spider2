with base as (

    select * 
    from {{ ref('stg_apple_store__crashes_app_version_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_apple_store__crashes_app_version_tmp')),
                staging_columns=get_crashes_app_version_columns()
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
        cast(device as {{ dbt.type_string() }}) as device,
        cast(app_version as {{ dbt.type_string() }}) as app_version,
        cast(crashes as {{ dbt.type_bigint() }}) as crashes
    from fields
)

select * 
from final
