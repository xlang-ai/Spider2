--To disable this model, set the using_bill_payment variable within your dbt_project.yml file to False.
{{ config(enabled=var('using_bill', True)) }}

with base as (

    select * 
    from {{ ref('stg_quickbooks__bill_payment_tmp') }}

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
                source_columns=adapter.get_columns_in_relation(ref('stg_quickbooks__bill_payment_tmp')),
                staging_columns=get_bill_payment_columns()
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
        cast(id as {{ dbt.type_string() }}) as bill_payment_id,
        cast(check_bank_account_id as {{ dbt.type_string() }}) as check_bank_account_id,
        check_print_status,
        cast(credit_card_account_id as {{ dbt.type_string() }}) as credit_card_account_id,
        exchange_rate,
        currency_id,
        cast(department_id as {{ dbt.type_string() }}) as department_id,
        pay_type,
        total_amount,
        cast( {{ dbt.date_trunc('day', 'transaction_date') }} as date) as transaction_date,
        cast(vendor_id as {{ dbt.type_string() }}) as vendor_id,
        _fivetran_deleted,
        source_relation
    from fields
)

select * 
from final
where not coalesce(_fivetran_deleted, false)
