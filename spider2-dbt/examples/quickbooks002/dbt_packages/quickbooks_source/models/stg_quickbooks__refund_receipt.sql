--To disable this model, set the using_refund_receipt variable within your dbt_project.yml file to False.
{{ config(enabled=var('using_refund_receipt', True)) }}

with base as (

    select * 
    from {{ ref('stg_quickbooks__refund_receipt_tmp') }}

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
                source_columns=adapter.get_columns_in_relation(ref('stg_quickbooks__refund_receipt_tmp')),
                staging_columns=get_refund_receipt_columns()
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
        cast(id as {{ dbt.type_string() }}) as refund_id,
        balance,
        cast(doc_number as {{ dbt.type_string() }}) as doc_number,
        total_amount,
        cast(class_id as {{ dbt.type_string() }}) as class_id,
        cast(deposit_to_account_id as {{ dbt.type_string() }}) as deposit_to_account_id,
        created_at,
        cast(department_id as {{ dbt.type_string() }}) as department_id,
        cast(customer_id as {{ dbt.type_string() }}) as customer_id,
        currency_id,
        exchange_rate,
        date_trunc('day', cast(transaction_date as date)) as transaction_date,
        _fivetran_deleted,
        source_relation
    from fields
)

select * 
from final
where not coalesce(_fivetran_deleted, false)
