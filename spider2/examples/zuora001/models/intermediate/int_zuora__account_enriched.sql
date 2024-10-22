with account as (

    select * 
    from {{ var('account') }} 
    where is_most_recent_record 
),

billing_history as (

    select * 
    from {{ ref('zuora__billing_history') }}
), 

subscription as (

    select * 
    from {{ var('subscription') }} 
    where is_most_recent_record
), 

invoice_item as (

    select * 
    from {{ var('invoice_item')}}
    where is_most_recent_record
),

account_payment_data as (

    select 
        account_id,
        sum(amount) as account_amount_paid
    from {{ var('payment') }} 
    where is_most_recent_record
        and account_id is not null
    {{ dbt_utils.group_by(1) }}
),

account_details as (

    select 
        account_id,
        created_date,
        name,
        account_number,
        credit_balance, 
        mrr,
        status,
        auto_pay, 
        {{ dbt_utils.safe_divide( dbt.datediff("account.created_date", dbt.current_timestamp_backcompat(), "day"), 30) }} as account_active_months,
        case when {{ dbt.datediff("account.created_date", dbt.current_timestamp_backcompat(), "day") }} <= 30
            then true else false end as is_new_customer
    
        {{ fivetran_utils.persist_pass_through_columns('zuora_account_pass_through_columns') }}

    from account

),

account_totals as (

    select 
        account_id,
        max(most_recent_payment_date) as most_recent_payment_date,

        {% if var('zuora__using_credit_balance_adjustment', true) %}
        max(most_recent_credit_balance_adjustment_date) as most_recent_credit_balance_adjustment_date,
        {% endif %}

        sum(case when cast({{ dbt.date_trunc('day', dbt.current_timestamp_backcompat()) }} as date) > due_date
                and invoice_amount != invoice_amount_paid 
                then invoice_amount_unpaid else 0 end) as total_amount_past_due
        
        {% set sum_cols = ['refund_amount', 'discount_charges', 'tax_amount', 'invoice_amount', 'invoice_amount_home_currency', 'invoice_amount_paid', 'invoice_amount_unpaid'] %}
        {% for col in sum_cols %}
        , sum({{ col }}) as total_{{ col }} 
        {% endfor %}

    from billing_history
    {{ dbt_utils.group_by(1) }}
),

account_invoice_data as (

    select 
        account_id,
        min(charge_date) as first_charge_date,
        max(charge_date) as most_recent_charge_date,
        count(distinct invoice_item_id) as invoice_item_count,
        count(distinct invoice_id) as invoice_count
    from invoice_item
    {{ dbt_utils.group_by(1) }}
),

account_subscription_data as (

    select 
        account_id,
        count(distinct subscription_id) as subscription_count,
        sum(case when lower(status) = 'active' then 1 else 0 end) as active_subscription_count
    from subscription
    {{ dbt_utils.group_by(1) }}
),

account_cumulatives as (
    
    select 
        account_totals.account_id,
        account_details.created_date,
        account_details.name,
        account_details.account_number,
        account_details.credit_balance, 
        account_details.mrr,
        account_details.status,
        account_details.auto_pay,
        account_details.account_active_months,
        account_details.is_new_customer

        {{ fivetran_utils.persist_pass_through_columns('zuora_account_pass_through_columns', identifier = 'account_details') }},

        account_totals.total_tax_amount as total_taxes,
        account_totals.total_refund_amount as total_refunds,
        account_totals.total_discount_charges as total_discounts,
        account_totals.total_invoice_amount,
        account_totals.total_invoice_amount_home_currency,
        account_totals.total_invoice_amount_paid as total_amount_paid,
        account_totals.total_invoice_amount_unpaid as total_amount_not_paid,
        account_totals.total_amount_past_due,
        account_totals.most_recent_payment_date,

        {% if var('zuora__using_credit_balance_adjustment', true) %}
        account_totals.most_recent_credit_balance_adjustment_date, 
        {% endif %}
        
        account_invoice_data.first_charge_date,
        account_invoice_data.most_recent_charge_date,
        account_invoice_data.invoice_item_count,
        account_invoice_data.invoice_count,
        round(cast({{ dbt_utils.safe_divide('account_totals.total_invoice_amount', 'account_invoice_data.invoice_count') }} as {{ dbt.type_numeric() }}), 2) as total_average_invoice_value,
        round(cast({{ dbt_utils.safe_divide('account_invoice_data.invoice_item_count', 'account_invoice_data.invoice_count') }} as {{ dbt.type_numeric() }}), 2) as total_units_per_invoice,
        account_subscription_data.subscription_count as total_subscription_count,
        account_subscription_data.active_subscription_count,
        case when account_subscription_data.active_subscription_count = 0 then false else true end as is_currently_subscribed,
        account_payment_data.account_amount_paid
    from account_details
        left join account_totals
            on account_details.account_id = account_totals.account_id
        left join account_invoice_data
            on account_totals.account_id = account_invoice_data.account_id
        left join account_subscription_data
            on account_totals.account_id = account_subscription_data.account_id
        left join account_payment_data
            on account_totals.account_id = account_payment_data.account_id
)

select * 
from account_cumulatives
