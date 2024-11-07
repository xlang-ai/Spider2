--To disable this model, set the using_vendor_credit variable within your dbt_project.yml file to False.
{{ config(enabled=var('using_vendor_credit', True)) }}

with base as (

    select * 
    from {{ ref('stg_quickbooks__vendor_credit_line_tmp') }}

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
                source_columns=adapter.get_columns_in_relation(ref('stg_quickbooks__vendor_credit_line_tmp')),
                staging_columns=get_vendor_credit_line_columns()
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
        cast(vendor_credit_id as {{ dbt.type_string() }}) as vendor_credit_id,
        index,
        cast(account_expense_customer_id as {{ dbt.type_string() }}) as account_expense_customer_id,
        cast(account_expense_account_id as {{ dbt.type_string() }}) as account_expense_account_id,
        account_expense_billable_status,
        account_expense_tax_code_id,
        cast(account_expense_class_id as {{ dbt.type_string() }}) as account_expense_class_id,
        cast(item_expense_customer_id as {{ dbt.type_string() }}) as item_expense_customer_id,
        cast(item_expense_item_id as {{ dbt.type_string() }}) as item_expense_item_id,
        item_expense_quantity,
        item_expense_unit_price,
        cast(item_expense_class_id as {{ dbt.type_string() }}) as item_expense_class_id,
        item_expense_billable_status,
        amount,
        description,
        source_relation
    from fields
)

select * 
from final
