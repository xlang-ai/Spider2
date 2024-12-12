{% set sum_cols = ['invoice_amount', 'invoice_amount_paid', 'invoice_amount_unpaid', 'discount_charges'] %}
{% do sum_cols.append('tax_amount') if var('zuora__using_taxation_item', true) %}
{% do sum_cols.append('credit_balance_adjustment_amount') if var('zuora__using_credit_balance_adjustment', true) %}


with invoice_joined as (

    select *
    from {{ ref('zuora__billing_history') }}
),

transactions_grouped as (

    select 
        account_id, 
        invoice_date as date_day,             
        cast({{ dbt.date_trunc("week", "invoice_date") }} as date) as date_week, 
        cast({{ dbt.date_trunc("month", "invoice_date") }} as date) as date_month, 
        cast({{ dbt.date_trunc("year", "invoice_date") }} as date) as date_year, 
        count(distinct invoice_id) as daily_invoices,
        sum(invoice_items) as daily_invoice_items,

        {% for col in sum_cols %}
        {% if var('zuora__using_multicurrency', false) %}
            sum({{ col }}) as daily_{{ col }},
        {% else %} 
            sum({{ col }}_home_currency) as daily_{{ col }},
        {% endif %}
        {% endfor %}

        sum(refund_amount) as daily_refunds 

    from invoice_joined
    {{ dbt_utils.group_by(5) }}
)

select *
from transactions_grouped
