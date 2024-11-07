--To disable this model, set the using_bill and using_bill_payment variables within your dbt_project.yml file to False.
{{ config(enabled=var('using_bill', True)) }}

with base as (

    select * 
    from {{ ref('stg_quickbooks__bill_linked_txn_tmp') }}

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
                source_columns=adapter.get_columns_in_relation(ref('stg_quickbooks__bill_linked_txn_tmp')),
                staging_columns=get_bill_linked_txn_columns()
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
        cast(bill_id as {{ dbt.type_string() }}) as bill_id,
        index,
        cast(bill_payment_id as {{ dbt.type_string() }}) as bill_payment_id,
        source_relation
    from fields
)

select * 
from final
