{% set round_cols = ['invoice_amount', 'invoice_amount_paid', 'invoice_amount_unpaid', 'discount_charges', 'refunds'] %}
{% do round_cols.append('tax_amount') if var('zuora__using_taxation_item', true) %}
{% do round_cols.append('credit_balance_adjustment_amount') if var('zuora__using_credit_balance_adjustment', true) %}

with account_running_totals as (

    select *
    from {{ ref('int_zuora__account_running_totals') }}
),

account_overview as (

    select * 
    from {{ ref('zuora__account_overview') }}
),

account_daily_overview as (

    select 
        account_running_totals.account_daily_id,
        account_running_totals.account_id,
        account_running_totals.date_day,        
        account_running_totals.date_week, 
        account_running_totals.date_month, 
        account_running_totals.date_year,  
        account_running_totals.date_index,  
        account_overview.account_created_at,
        account_overview.account_name,
        account_overview.account_number,
        account_overview.account_status,
        account_overview.account_country,
        account_overview.account_email,
        account_overview.account_first_name,
        account_overview.account_last_name,
        account_overview.account_postal_code,
        account_overview.account_state, 
        account_overview.first_charge_processed_at
        
        {{ fivetran_utils.persist_pass_through_columns('zuora_account_pass_through_columns', identifier='account_overview') }},

        account_running_totals.daily_invoices,
        account_running_totals.daily_invoice_items,

        {% for col in round_cols %}
            round(cast(daily_{{ col }} as {{ dbt.type_numeric() }}), 2) as daily_{{ col }},
        {% endfor %}

        account_running_totals.rolling_invoices,
        account_running_totals.rolling_invoice_items,

        {% for col in round_cols %}
            round(cast(rolling_{{ col }} as {{ dbt.type_numeric() }}), 2) as rolling_{{ col }}
            {{ ',' if not loop.last }}
        {% endfor %}

    from account_running_totals
    left join account_overview
        on account_running_totals.account_id = account_overview.account_id
)

select * 
from account_daily_overview