with account_enriched as (

    select * 
    from {{ ref('int_zuora__account_enriched') }} 
),

contact as (

    select *
    from {{ var('contact') }} 
    where is_most_recent_record
    and is_most_recent_account_contact 
),

account_overview as (
    
    select 
        account_enriched.account_id, 
        account_enriched.created_date as account_created_at,
        account_enriched.name as account_name,
        account_enriched.account_number,
        account_enriched.credit_balance as account_credit_balance,
        account_enriched.mrr as account_zuora_calculated_mrr,
        account_enriched.status as account_status,
        account_enriched.auto_pay as is_auto_pay,
        contact.country as account_country,
        contact.city as account_city,
        contact.work_email as account_email,
        contact.first_name as account_first_name, 
        contact.last_name as account_last_name,
        contact.postal_code as account_postal_code,
        contact.state as account_state,
        account_enriched.account_active_months,
        account_enriched.first_charge_date as first_charge_processed_at,
        account_enriched.is_currently_subscribed,
        account_enriched.is_new_customer,
        account_enriched.invoice_item_count,
        account_enriched.invoice_count,
    
        {% set round_cols = ['active_subscription_count', 'total_subscription_count', 'total_invoice_amount', 'total_invoice_amount_home_currency', 'total_taxes', 'total_discounts', 'total_amount_paid', 'total_amount_not_paid', 'total_amount_past_due', 'total_refunds'] %}
        {% for col in round_cols %}
            round(cast({{ col }} as {{ dbt.type_numeric() }}), 2) as {{ col }},   
        {% endfor %}

        account_enriched.total_average_invoice_value,
        account_enriched.total_units_per_invoice,

        {% set avg_cols = ['subscription_count', 'invoice_amount', 'invoice_amount_home_currency', 'taxes', 'discounts', 'amount_paid', 'amount_not_paid', 'amount_past_due', 'refunds'] %}
        {% for col in avg_cols %}
            round(cast({{- dbt_utils.safe_divide('total_' ~ col, 'account_active_months') }} as {{ dbt.type_numeric() }} ), 2) as monthly_average_{{ col }}
            {{ ',' if not loop.last -}}
        {% endfor %}

        {{ fivetran_utils.persist_pass_through_columns('zuora_account_pass_through_columns', identifier='account_enriched') }}

    from account_enriched
    left join contact 
        on account_enriched.account_id = contact.account_id
)

select * 
from account_overview