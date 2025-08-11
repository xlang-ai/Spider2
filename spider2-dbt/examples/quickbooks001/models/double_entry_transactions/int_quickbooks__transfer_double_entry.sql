/*
Table that creates a debit record to the receiveing account and a credit record to the sending account.
*/

--To disable this model, set the using_transfer variable within your dbt_project.yml file to False.
{{ config(enabled=var('using_transfer', True)) }}

with transfers as (

    select *
    from {{ ref('stg_quickbooks__transfer') }}
),

transfer_body as (

    select
        transfer_id as transaction_id,
        source_relation,
        row_number() over(partition by transfer_id, source_relation 
            order by source_relation, transaction_date) - 1 as index,
        transaction_date,
        amount,
        amount as converted_amount,
        from_account_id as credit_to_account_id,
        to_account_id as debit_to_account_id
    from transfers
),

final as (

    select
        transaction_id,
        source_relation,
        index,
        transaction_date,
        cast(null as {{ dbt.type_string() }}) as customer_id,
        cast(null as {{ dbt.type_string() }}) as vendor_id,
        amount,
        converted_amount,
        credit_to_account_id as account_id,
        cast(null as {{ dbt.type_string() }}) as class_id,
        cast(null as {{ dbt.type_string() }}) as department_id,
        'credit' as transaction_type,
        'transfer' as transaction_source
    from transfer_body

    union all

    select
        transaction_id,
        source_relation,
        index,
        transaction_date,
        cast(null as {{ dbt.type_string() }}) as customer_id,
        cast(null as {{ dbt.type_string() }}) as vendor_id,
        amount,
        converted_amount,
        debit_to_account_id as account_id,
        cast(null as {{ dbt.type_string() }}) as class_id,
        cast(null as {{ dbt.type_string() }}) as department_id,
        'debit' as transaction_type,
        'transfer' as transaction_source
    from transfer_body
)

select *
from final
