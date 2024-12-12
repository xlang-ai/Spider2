{% set fields = ['invoices','invoice_items','invoice_amount','invoice_amount_paid','invoice_amount_unpaid','discount_charges','refunds'] %}
{% do fields.append('tax_amount') if var('zuora__using_taxation_item', true) %}
{% do fields.append('credit_balance_adjustment_amount') if var('zuora__using_credit_balance_adjustment', true) %}

with account_partitions as (

    select * 
    from {{ ref('int_zuora__account_partitions') }}
),

account_running_totals as (

    select
        account_id,
        {{ dbt_utils.generate_surrogate_key(['account_id','date_day']) }} as account_daily_id,
        date_day,        
        date_week, 
        date_month, 
        date_year,  
        date_index, 

        {% for f in fields %}
            coalesce(daily_{{ f }}, 0) as daily_{{ f }},
        {% endfor %} 

        {% for f in fields %}
            coalesce(rolling_{{ f }},   
                first_value(rolling_{{ f }}) over (partition by rolling_{{ f }}_partition order by date_day rows unbounded preceding)) as rolling_{{ f }}
        {%- if not loop.last -%},
        {%- endif -%}
        {% endfor %}
        
    from account_partitions
)

select *
from account_running_totals