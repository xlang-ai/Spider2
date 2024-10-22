with invoice_item_enriched as (

    select 
        invoice_id,
        count(distinct invoice_item_id) as invoice_items,
        count(distinct product_id) as products,
        count(distinct subscription_id) as subscriptions,
        sum(case when cast(processing_type as {{ dbt.type_string() }}) = '1' then charge_amount else 0 end) as discount_charges,
        sum(case when cast(processing_type as {{ dbt.type_string() }}) = '1' then charge_amount_home_currency else 0 end) as discount_charges_home_currency,
        sum(quantity) as units,
        min(charge_date) as first_charge_date,
        max(charge_date) as most_recent_charge_date,
        min(service_start_date) as invoice_service_start_date,
        max(service_end_date) as invoice_service_end_date
    from {{ var('invoice_item') }}
    where is_most_recent_record
    {{ dbt_utils.group_by(1) }}
),

invoice_payment as (

    select 
        invoice_id,
        payment_id
    from {{ var('invoice_payment') }} 
    where is_most_recent_record
),

payment as (

    select
        payment_id,
        payment_number,
        effective_date as payment_date,
        status as payment_status,
        type as payment_type, 
        amount_home_currency as payment_amount_home_currency,
        payment_method_id
    from {{ var('payment') }}
    where is_most_recent_record
),

payment_method as (
    
    select 
        payment_method_id,
        type as payment_method_type,
        coalesce(ach_account_type, bank_transfer_account_type, credit_card_type, paypal_type, sub_type) as payment_method_subtype,
        active as is_payment_method_active
    from {{ var('payment_method') }} 
    where is_most_recent_record
),

{% if var('zuora__using_credit_balance_adjustment', true) %}
credit_balance_adjustment as (

    select 
        invoice_id,
        credit_balance_adjustment_id,
        number as credit_balance_adjustment_number,
        reason_code as credit_balance_adjustment_reason_code,
        amount_home_currency as credit_balance_adjustment_amount_home_currency,
        adjustment_date as credit_balance_adjustment_date
    from {{ var('credit_balance_adjustment') }}
    where is_most_recent_record
),
{% endif %}

{% if var('zuora__using_taxation_item', true) %}
taxes as (

    select
        invoice_id, 
        sum(tax_amount_home_currency) as tax_amount_home_currency
    from {{ var('taxation_item') }} 
    where is_most_recent_record
    {{ dbt_utils.group_by(1) }}
),
{% endif %}

billing_enriched as (

    select 
        invoice_item_enriched.invoice_id,
        invoice_item_enriched.invoice_items,
        invoice_item_enriched.products,
        invoice_item_enriched.subscriptions,
        invoice_item_enriched.discount_charges,
        invoice_item_enriched.discount_charges_home_currency,
        invoice_item_enriched.units,
        invoice_item_enriched.first_charge_date,
        invoice_item_enriched.most_recent_charge_date,
        invoice_item_enriched.invoice_service_start_date,
        invoice_item_enriched.invoice_service_end_date,

        {% if var('zuora__using_taxation_item', true) %}
        taxes.tax_amount_home_currency,
        {% endif %}

        count(distinct payment.payment_id) as payments, 
        sum(payment_amount_home_currency) as invoice_amount_paid_home_currency,
        min(payment_date) as first_payment_date,
        max(payment_date) as most_recent_payment_date, 
        count(distinct payment_method.payment_method_id) as payment_methods

        {% if var('zuora__using_credit_balance_adjustment', true) %}
        , count(distinct credit_balance_adjustment_id) as credit_balance_adjustments
        , sum(credit_balance_adjustment_amount_home_currency) as credit_balance_adjustment_amount_home_currency
        , min(credit_balance_adjustment_date) as first_credit_balance_adjustment_date
        , max(credit_balance_adjustment_date) as most_recent_credit_balance_adjustment_date
        {% endif %}

    from invoice_item_enriched
    left join invoice_payment 
        on invoice_item_enriched.invoice_id = invoice_payment.invoice_id
    left join payment
        on invoice_payment.payment_id = payment.payment_id
    left join payment_method
        on payment.payment_method_id = payment_method.payment_method_id
    
    {% if var('zuora__using_credit_balance_adjustment', true) %}
    left join credit_balance_adjustment
        on invoice_item_enriched.invoice_id = credit_balance_adjustment.invoice_id 
    {% endif %}

    {% if var('zuora__using_taxation_item', true) %}
    left join taxes
        on invoice_item_enriched.invoice_id = taxes.invoice_id
    {% endif %}

    {{ dbt_utils.group_by(12) if var('zuora__using_taxation_item', true) else dbt_utils.group_by(11) }} 
)

select * 
from billing_enriched