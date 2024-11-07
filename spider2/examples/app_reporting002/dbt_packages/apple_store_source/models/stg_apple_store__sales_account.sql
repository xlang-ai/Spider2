with base as (

    select * 
    from {{ ref('stg_apple_store__sales_account_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_apple_store__sales_account_tmp')),
                staging_columns=get_sales_account_columns()
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
        cast(id as {{ dbt.type_bigint() }}) as account_id,
        cast(name as {{ dbt.type_string() }}) as account_name
    from fields
)

select * 
from final
