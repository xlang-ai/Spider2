--To disable this model, set the using_invoice variable within your dbt_project.yml file to False.
{{ config(enabled=var('using_invoice') and var('using_payment', True)) }}

with invoices as (

    select *
    from {{ ref('stg_quickbooks__invoice') }}
),

invoice_linked as (

    select *
    from {{ ref('stg_quickbooks__invoice_linked_txn') }}
),

{% if var('using_estimate', True) %}
estimates as (

    select *
    from {{ ref('stg_quickbooks__estimate') }}
),
{% endif %}

payments as (

    select *
    from {{ ref('stg_quickbooks__payment') }}
),

payment_lines_payment as (

    select *
    from {{ ref('stg_quickbooks__payment_line') }}

    where invoice_id is not null
),

invoice_est as (

    select
        invoices.invoice_id,
        invoice_linked.estimate_id,
        invoices.source_relation
    from invoices

    left join invoice_linked
        on invoices.invoice_id = invoice_linked.invoice_id
        and invoices.source_relation = invoice_linked.source_relation

    where invoice_linked.estimate_id is not null
),

invoice_pay as (

    select
        invoices.invoice_id,
        invoice_linked.payment_id,
        invoices.source_relation
    from invoices

    left join invoice_linked
        on invoices.invoice_id = invoice_linked.invoice_id
        and invoices.source_relation = invoice_linked.source_relation

    where invoice_linked.payment_id is not null
),

invoice_link as (

    select
        invoices.*,
        invoice_est.estimate_id,
        invoice_pay.payment_id
    from invoices

    left join invoice_est
        on invoices.invoice_id = invoice_est.invoice_id
        and invoices.source_relation = invoice_est.source_relation

    left join invoice_pay
        on invoices.invoice_id = invoice_pay.invoice_id
        and invoices.source_relation = invoice_pay.source_relation
),

final as (

    select
        cast('invoice' as {{ dbt.type_string() }}) as transaction_type,
        invoice_link.invoice_id as transaction_id,
        invoice_link.source_relation,
        invoice_link.doc_number,
        invoice_link.estimate_id,
        invoice_link.department_id,
        invoice_link.customer_id as customer_id,
        invoice_link.billing_address_id,
        invoice_link.shipping_address_id,
        invoice_link.delivery_type,
        invoice_link.total_amount as total_amount,
        (invoice_link.total_amount * coalesce(invoice_link.exchange_rate, 1)) as total_converted_amount,
        invoice_link.balance as current_balance,

        {% if var('using_estimate', True) %}
        coalesce(estimates.total_amount, 0) as estimate_total_amount,
        coalesce(estimates.total_amount, 0) * coalesce(estimates.exchange_rate, 1) as estimate_total_converted_amount,
        estimates.transaction_status as estimate_status,

        {% else %}
        cast(null as {{ dbt.type_numeric() }}) as estimate_total_amount,
        cast(null as {{ dbt.type_numeric() }}) as estimate_total_converted_amount,
        cast(null as {{ dbt.type_string() }}) as estimate_status,

        {% endif %}

        invoice_link.due_date as due_date,
        min(payments.transaction_date) as initial_payment_date,
        max(payments.transaction_date) as recent_payment_date,
        sum(coalesce(payment_lines_payment.amount, 0)) as total_current_payment,
        sum(coalesce(payment_lines_payment.amount, 0) * coalesce(payments.exchange_rate, 1)) as total_current_converted_payment

    from invoice_link

    {% if var('using_estimate', True) %}
    left join estimates
        on invoice_link.estimate_id = estimates.estimate_id
        and invoice_link.source_relation = estimates.source_relation
    {% endif %}
    left join payments
        on invoice_link.payment_id = payments.payment_id
        and invoice_link.source_relation = payments.source_relation

    left join payment_lines_payment
        on payments.payment_id = payment_lines_payment.payment_id
        and payments.source_relation = payment_lines_payment.source_relation
        and invoice_link.invoice_id = payment_lines_payment.invoice_id
        and invoice_link.source_relation = payment_lines_payment.source_relation


    {{ dbt_utils.group_by(17) }} 
)

select * 
from final