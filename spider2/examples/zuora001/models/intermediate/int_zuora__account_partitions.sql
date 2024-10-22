{% set fields = ['rolling_invoices','rolling_invoice_items','rolling_invoice_amount','rolling_invoice_amount_paid','rolling_invoice_amount_unpaid','rolling_discount_charges','rolling_refunds'] %}
{% do fields.append('rolling_tax_amount') if var('zuora__using_taxation_item', true) %}
{% do fields.append('rolling_credit_balance_adjustment_amount') if var('zuora__using_credit_balance_adjustment', true) %}

with account_rolling_totals as (

    select * 
    from {{ ref('int_zuora__account_rolling_totals') }}
),

account_partitions as (

    select
        *,

        {% for f in fields %}
        sum(case when {{ f }} is null  
            then 0  
            else 1  
                end) over (order by account_id, date_day rows unbounded preceding) as {{ f }}_partition
        {%- if not loop.last -%},{%- endif -%}
        {% endfor %}              

    from account_rolling_totals
)

select * 
from account_partitions