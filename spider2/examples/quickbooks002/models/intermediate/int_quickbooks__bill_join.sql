--To disable this model, set the using_bill variable within your dbt_project.yml file to False.
{{ config(enabled=var('using_bill', True)) }}

with bills as (

    select *
    from {{ ref('stg_quickbooks__bill') }}
),

bill_lines as (

    select *
    from {{ ref('stg_quickbooks__bill_line') }}
),

bills_linked as (

    select *
    from {{ ref('stg_quickbooks__bill_linked_txn') }}
),

bill_payments as (

    select *
    from {{ ref('stg_quickbooks__bill_payment') }}
),

bill_payment_lines as (

    select *
    from {{ ref('stg_quickbooks__bill_payment_line') }}

    where bill_id is not null
),

bill_pay as (

    select
        bills.bill_id,
        bills.source_relation,
        bills_linked.bill_payment_id
    from bills

    left join bills_linked
        on bills.bill_id = bills_linked.bill_id
        and bills.source_relation = bills_linked.source_relation

    where bills_linked.bill_payment_id is not null
),

bill_link as (

    select
        bills.*,
        bill_pay.bill_payment_id
    from bills

    left join bill_pay
        on bills.bill_id = bill_pay.bill_id
        and bills.source_relation = bill_pay.source_relation
),

final as (

    select
        cast('bill' as {{ dbt.type_string() }})  as transaction_type,
        bill_link.bill_id as transaction_id,
        bill_link.source_relation,
        bill_link.doc_number,
        bill_link.department_id,
        bill_link.vendor_id as vendor_id,
        bill_link.payable_account_id,
        bill_link.total_amount as total_amount,
        (bill_link.total_amount * coalesce(bill_link.exchange_rate, 1)) as total_converted_amount,
        bill_link.balance as current_balance,
        bill_link.due_date_at as due_date,
        min(bill_payments.transaction_date) as initial_payment_date,
        max(bill_payments.transaction_date) as recent_payment_date,
        sum(coalesce(bill_payment_lines.amount, 0)) as total_current_payment,
        sum(coalesce(bill_payment_lines.amount, 0) * coalesce(bill_payments.exchange_rate, 1)) as total_current_converted_payment

    from bill_link

    left join bill_payments
        on bill_link.bill_payment_id = bill_payments.bill_payment_id
        and bill_link.source_relation = bill_payments.source_relation

    left join bill_payment_lines
        on bill_payments.bill_payment_id = bill_payment_lines.bill_payment_id
        and bill_payments.source_relation = bill_payment_lines.source_relation
        and bill_link.bill_id = bill_payment_lines.bill_id
        and bill_link.source_relation = bill_payment_lines.source_relation
    
    {{ dbt_utils.group_by(11) }} 
)

select * 
from final