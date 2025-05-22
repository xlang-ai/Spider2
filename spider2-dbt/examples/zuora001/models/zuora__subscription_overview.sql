with subscription as (

    select *
    from {{ var('subscription') }}  
    where is_most_recent_record
),

rate_plan_charge as (

    select * 
    from {{ var('rate_plan_charge') }}
    where is_most_recent_record
),

amendment as (

    select *
    from {{ var('amendment') }}
    where is_most_recent_record
),


account_overview as (

    select 
        account_id,
        account_name
    from {{ ref('zuora__account_overview') }} 
),

subscription_overview as (

    select  
        {{ dbt_utils.generate_surrogate_key(['subscription.subscription_id', 'rate_plan_charge.rate_plan_charge_id', 'amendment.amendment_id']) }} as subscription_key,
        subscription.subscription_id,
        subscription.account_id,
        account_overview.account_name,
        subscription.auto_renew,
        subscription.cancel_reason,
        subscription.cancelled_date,
        subscription.current_term, 
        subscription.current_term_period_type, 
        subscription.initial_term,
        subscription.initial_term_period_type, 
        subscription.is_latest_version,
        subscription.previous_subscription_id,
        subscription.renewal_term,
        subscription.renewal_term_period_type,
        subscription.service_activation_date,
        subscription.status,
        subscription.subscription_start_date,
        subscription.subscription_end_date,
        subscription.term_start_date,
        subscription.term_end_date,
        subscription.term_type,
        subscription.version,
        rate_plan_charge.rate_plan_charge_id, 
        rate_plan_charge.name as rate_plan_charge_name,
        rate_plan_charge.billing_period as charge_billing_period,
        rate_plan_charge.billing_timing as charge_billing_timing,
        rate_plan_charge.charge_model,
        rate_plan_charge.charge_type,
        rate_plan_charge.charged_through_date,
        rate_plan_charge.effective_start_date as charge_effective_start_date,
        rate_plan_charge.effective_end_date as charge_effective_end_date,
        rate_plan_charge.mrr as charge_mrr,
        rate_plan_charge.mrrhome_currency as charge_mrr_home_currency,
        amendment.amendment_id,
        amendment.name as amendment_name,
        amendment.booking_date as amendment_booking_date,
        amendment.created_date as amendment_creation_date,
        amendment.type as amendment_type,
        amendment.status as amendment_status,
        amendment.contract_effective_date as amendment_contract_date,
        amendment.service_activation_date as amendment_activation_date,

        {% set interval_cols = ['current_term', 'initial_term', 'renewal_term'] %}
        {% for interval_col in interval_cols %}
        case when subscription.{{ interval_col }}_period_type = 'Week' then 7 * subscription.{{ interval_col }}
            when subscription.{{ interval_col }}_period_type = 'Month' then 30 * subscription.{{ interval_col }}
            when subscription.{{ interval_col }}_period_type = 'Year' then 365 * subscription.{{ interval_col }}
            else subscription.{{ interval_col }} 
            end as {{ interval_col }}_days,
        {% endfor %}

        {% set date_cols = ['subscription', 'term'] %}
        {% for date_col in date_cols %}
        case when subscription.term_type = 'TERMED'
            then {{ dbt.datediff('subscription.' ~ date_col ~ '_start_date', 'subscription.' ~ date_col ~ '_end_date', 'day') }} 
            when subscription.term_type = 'EVERGREEN' and subscription.cancelled_date is not null
            then {{ dbt.datediff('subscription.' ~ date_col ~ '_start_date', 'subscription.cancelled_date', 'day') }}
            else {{ dbt.datediff('subscription.' ~ date_col ~ '_start_date', dbt.current_timestamp_backcompat(), 'day') }}
            end as {{ date_col }}_days
        {{ ',' if not loop.last -}}
        {% endfor %}

        {{ fivetran_utils.persist_pass_through_columns('zuora_subscription_pass_through_columns', identifier='subscription') }}

        {{ fivetran_utils.persist_pass_through_columns('zuora_rate_plan_charge_pass_through_columns', identifier='rate_plan_charge') }}

    from subscription
    left join rate_plan_charge
        on subscription.subscription_id = rate_plan_charge.subscription_id
    left join amendment
        on subscription.subscription_id = amendment.subscription_id
    left join account_overview 
        on subscription.account_id = account_overview.account_id
)

select * 
from subscription_overview