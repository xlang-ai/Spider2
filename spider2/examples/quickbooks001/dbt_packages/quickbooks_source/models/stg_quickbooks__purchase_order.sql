--To enable this model, set the using_invoice variable within your dbt_project.yml file to True.
{{ config(enabled=var('using_purchase_order', False)) }}

with base as (

    select *
    from {{ ref('stg_quickbooks__purchase_order_tmp') }}

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
                source_columns=adapter.get_columns_in_relation(ref('stg_quickbooks__purchase_order_tmp')),
                staging_columns=get_purchase_order_columns()
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
        cast(id as {{ dbt.type_string() }}) as purchase_order_id,
        created_at,
        custom_po_number,
        cast(doc_number as {{ dbt.type_string() }}) as doc_number,
        currency_id,
        exchange_rate,
        total_amount,
        cast(payable_account_id as {{ dbt.type_string() }}) as payable_account_id,
        cast(vendor_id as {{ dbt.type_string() }}) as vendor_id,
        cast( {{ dbt.date_trunc('day', 'transaction_date') }} as date) as transaction_date,
        status,
        cast( {{ dbt.date_trunc('day', 'due_date') }} as date) as due_date, 
        _fivetran_deleted,
        source_relation
    from fields
)

select *
from final
where not coalesce(_fivetran_deleted, false)
