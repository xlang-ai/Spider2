/*
Table that creates a debit record to the associated bank account and a credit record to the specified credit card account.
*/

--To enable this model, set the using_credit_card_payment_txn variable within your dbt_project.yml file to True.
{{ config(enabled=var('using_credit_card_payment_txn', False)) }}

with credit_card_payments as (
    
    select *
    from {{ ref('stg_quickbooks__credit_card_payment_txn') }}
    where is_most_recent_record
),

credit_card_payment_prep as (

    select
        credit_card_payments.credit_card_payment_id as transaction_id,
        credit_card_payments.source_relation,
        row_number() over (partition by credit_card_payments.credit_card_payment_id, credit_card_payments.source_relation 
            order by credit_card_payments.source_relation, credit_card_payments.transaction_date) - 1 as index,
        credit_card_payments.transaction_date,
        credit_card_payments.amount,
        credit_card_payments.amount as converted_amount,
        credit_card_payments.bank_account_id,
        credit_card_payments.credit_card_account_id,
        cast(null as {{ dbt.type_string() }}) as customer_id,
        cast(null as {{ dbt.type_string() }}) as vendor_id,
        cast(null as {{ dbt.type_string() }}) as class_id,
        cast(null as {{ dbt.type_string() }}) as department_id
    from credit_card_payments
),

final as (

    select
        transaction_id,
        source_relation,
        index,
        transaction_date,
        customer_id,
        vendor_id,
        amount, 
        converted_amount,
        cast(bank_account_id as {{ dbt.type_string() }}) as account_id,
        class_id,
        department_id,
        'credit' as transaction_type,
        'credit card payment' as transaction_source
    from credit_card_payment_prep

    union all

    select 
        transaction_id,
        source_relation,
        index,
        transaction_date,
        customer_id,
        vendor_id,
        amount,
        converted_amount,
        cast(credit_card_account_id as {{ dbt.type_string() }}) as account_id,
        class_id,
        department_id,
        'debit' as transaction_type,
        'credit card payment' as transaction_source
    from credit_card_payment_prep
)

select *
from final
