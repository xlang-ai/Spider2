--To disable this model, set the using_credit_memo variable within your dbt_project.yml file to False.
{{ config(enabled=var('using_credit_memo', True)) }}

with base as (

    select * 
    from {{ ref('stg_quickbooks__credit_memo_line_tmp') }}

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
                source_columns=adapter.get_columns_in_relation(ref('stg_quickbooks__credit_memo_line_tmp')),
                staging_columns=get_credit_memo_line_columns()
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
        cast(credit_memo_id as {{ dbt.type_string() }}) as credit_memo_id,
        index,
        amount,
        cast(sales_item_account_id as {{ dbt.type_string() }}) as sales_item_account_id,
        cast(sales_item_class_id as {{ dbt.type_string() }}) as sales_item_class_id,
        cast(sales_item_item_id as {{ dbt.type_string() }}) as sales_item_item_id,
        sales_item_quantity,
        sales_item_unit_price,
        cast(discount_account_id as {{ dbt.type_string() }}) as discount_account_id,
        cast(discount_class_id as {{ dbt.type_string() }}) as discount_class_id,
        description,
        source_relation
    from fields
)

select * 
from final
