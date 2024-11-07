with base as (

    select * 
    from {{ ref('stg_quickbooks__item_tmp') }}

),

fields as (

    select
        /*
        The below macro is used to generate the correct SQL for package staging models. It takes a list of columns 
        that are expected/needed (staging_columns from dbt_quickbooks_source/models/tmp/) and compares it with columns 
        in the source (source_columns from dbt_quickbooks_source/macros/).
        For more information refer to our dbt_fivetran_utils documentation (https://github.com/fivetran/dbt_fivetran_utils.git).
        */

        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_quickbooks__item_tmp')),
                staging_columns=get_item_columns()
            )
        }}
        
        {{ 
            fivetran_utils.source_relation(
                union_schema_variable='quickbooks_union_schemas', 
                union_database_variable='quickbooks_union_databases'
                ) 
        }}
    from base
),

final as (
    
    select 
        cast(id as {{ dbt.type_string() }}) as item_id,
        active as is_active,
        created_at,
        cast(income_account_id as {{ dbt.type_string() }}) as income_account_id,
        cast(asset_account_id as {{ dbt.type_string() }}) as asset_account_id,
        cast(expense_account_id as {{ dbt.type_string() }}) as expense_account_id,
        name,
        purchase_cost,
        taxable,
        type,
        unit_price,
        inventory_start_date,
        cast(parent_item_id as {{ dbt.type_string() }}) as parent_item_id,
        source_relation

    from fields
)

select * 
from final
