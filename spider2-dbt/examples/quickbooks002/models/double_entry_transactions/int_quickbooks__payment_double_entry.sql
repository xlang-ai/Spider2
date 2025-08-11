/*
Table that creates a debit record to either undeposited funds or a specified cash account and a credit record to accounts receivable.
*/

--To disable this model, set the using_payment variable within your dbt_project.yml file to False.
{{ config(enabled=var('using_payment', True)) }}

with payments as (

    select *
    from {{ ref('stg_quickbooks__payment') }}
),

payment_lines as (

    select *
    from {{ ref('stg_quickbooks__payment_line') }}
),

accounts as (

    select *
    from {{ ref('stg_quickbooks__account') }}
),

ar_accounts as (

    select
        account_id,
        currency_id,
        source_relation
    from accounts

    where account_type = '{{ var('quickbooks__accounts_receivable_reference', 'Accounts Receivable') }}'
        and is_active
        and not is_sub_account
),

payment_join as (

    select
        payments.payment_id as transaction_id,
        payments.source_relation,
        row_number() over(partition by payments.payment_id, payments.source_relation 
            order by payments.source_relation, payments.transaction_date) - 1 as index,
        payments.transaction_date,
        payments.total_amount as amount,
        (payments.total_amount * coalesce(payments.exchange_rate, 1)) as converted_amount,
        payments.deposit_to_account_id,
        payments.receivable_account_id,
        payments.customer_id,
        payments.currency_id
    from payments
),

final as (

    select
        transaction_id,
        payment_join.source_relation,
        index,
        transaction_date,
        customer_id,
        cast(null as {{ dbt.type_string() }}) as vendor_id,
        amount,
        converted_amount,
        deposit_to_account_id as account_id,
        cast(null as {{ dbt.type_string() }}) as class_id,
        cast(null as {{ dbt.type_string() }}) as department_id,
        'debit' as transaction_type,
        'payment' as transaction_source
    from payment_join

    union all

    select
        transaction_id,
        payment_join.source_relation,
        index,
        transaction_date,
        customer_id,
        cast(null as {{ dbt.type_string() }}) as vendor_id,
        amount,
        converted_amount,
        coalesce(receivable_account_id, ar_accounts.account_id) as account_id,
        cast(null as {{ dbt.type_string() }}) as class_id,
        cast(null as {{ dbt.type_string() }}) as department_id,
        'credit' as transaction_type,
        'payment' as transaction_source
    from payment_join

    left join ar_accounts
        on ar_accounts.currency_id = payment_join.currency_id
        and ar_accounts.source_relation = payment_join.source_relation
)

select *
from final
