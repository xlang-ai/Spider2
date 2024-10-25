{% set fields = ['invoices','invoice_items','invoice_amount','invoice_amount_paid','invoice_amount_unpaid','discount_charges','refunds'] %}
{% do fields.append('tax_amount') if var('zuora__using_taxation_item', true) %}
{% do fields.append('credit_balance_adjustment_amount') if var('zuora__using_credit_balance_adjustment', true) %}

with transaction_date_spine as (

    select * 
    from {{ ref('int_zuora__transaction_date_spine') }}
),

transactions_grouped as (

    select *
    from {{ ref('int_zuora__transactions_grouped') }}
), 

account_rolling as (
    
    select 
        *,
        {% for f in fields %}
            sum(daily_{{ f }}) over (partition by account_id order by date_day, account_id rows unbounded preceding) as rolling_{{ f }}
        {%- if not loop.last -%},{%- endif -%}
        {% endfor %}  
    from transactions_grouped
),

account_rolling_totals as (

    select 
        coalesce(account_rolling.account_id, transaction_date_spine.account_id) as account_id,
        coalesce(account_rolling.date_day, transaction_date_spine.date_day) as date_day,
        coalesce(account_rolling.date_week, transaction_date_spine.date_week) as date_week,
        coalesce(account_rolling.date_month, transaction_date_spine.date_month) as date_month,
        coalesce(account_rolling.date_year, transaction_date_spine.date_year) as date_year,
        account_rolling.daily_invoices,
        account_rolling.daily_invoice_items,
        account_rolling.daily_invoice_amount,
        account_rolling.daily_invoice_amount_paid,
        account_rolling.daily_invoice_amount_unpaid,

        {% if var('zuora__using_taxation_item', true) %}
        account_rolling.daily_tax_amount,
        {% endif %}

        {% if var('zuora__using_credit_balance_adjustment', true) %}
        account_rolling.daily_credit_balance_adjustment_amount,
        {% endif %}

        account_rolling.daily_discount_charges,
        account_rolling.daily_refunds,
        {% for f in fields %}
        case when account_rolling.rolling_{{ f }} is null and date_index = 1
            then 0
            else account_rolling.rolling_{{ f }}
            end as rolling_{{ f }},
        {% endfor %}
        transaction_date_spine.date_index

    from transaction_date_spine 
    left join account_rolling
        on account_rolling.account_id = transaction_date_spine.account_id 
        and account_rolling.date_day = transaction_date_spine.date_day
)

select * 
from account_rolling_totals