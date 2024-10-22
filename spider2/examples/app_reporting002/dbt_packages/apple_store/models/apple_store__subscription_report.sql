{{ config(enabled=var('apple_store__using_subscriptions', False)) }}

with subscription_summary as (

    select *
    from {{ ref('int_apple_store__sales_subscription_summary') }}
),

subscription_events as (

    select *
    from {{ ref('int_apple_store__sales_subscription_events') }}
),

country_codes as (
    
    select * 
    from {{ var('apple_store_country_codes') }}
),

reporting_grain_combined as (

    select
        source_relation,
        cast(date_day as date) as date_day,
        account_id,
        account_name,
        app_name,
        app_id,
        subscription_name,
        country,
        state 
    from subscription_summary
    union all
    select
        source_relation,
        cast(date_day as date) as date_day,
        account_id,
        account_name,
        app_name,
        app_id,
        subscription_name,
        country,
        state 
    from subscription_events
),

reporting_grain as (

    select 
        distinct *
    from reporting_grain_combined
),

joined as (

    select 
        reporting_grain.source_relation,
        reporting_grain.date_day,
        reporting_grain.account_id,
        reporting_grain.account_name, 
        reporting_grain.app_id,
        reporting_grain.app_name,
        reporting_grain.subscription_name, 
        case 
            when country_codes.alternative_country_name is null then country_codes.country_name
            else country_codes.alternative_country_name
        end as territory_long,
        reporting_grain.country as territory_short,
        reporting_grain.state,
        country_codes.region, 
        country_codes.sub_region,
        coalesce(subscription_summary.active_free_trial_introductory_offer_subscriptions, 0) as active_free_trial_introductory_offer_subscriptions,
        coalesce(subscription_summary.active_pay_as_you_go_introductory_offer_subscriptions, 0) as active_pay_as_you_go_introductory_offer_subscriptions,
        coalesce(subscription_summary.active_pay_up_front_introductory_offer_subscriptions, 0) as active_pay_up_front_introductory_offer_subscriptions,
        coalesce(subscription_summary.active_standard_price_subscriptions, 0) as active_standard_price_subscriptions
        {% for event_val in var('apple_store__subscription_events') %}
        {% set event_column = 'event_' ~ event_val | replace(' ', '_') | trim | lower %}
        , coalesce({{ 'subscription_events.' ~ event_column }}, 0)
            as {{ event_column }} 
        {% endfor %}
    from reporting_grain
    left join subscription_summary
        on reporting_grain.date_day = subscription_summary.date_day
        and reporting_grain.source_relation = subscription_summary.source_relation
        and reporting_grain.account_id =  subscription_summary.account_id 
        and reporting_grain.app_name = subscription_summary.app_name
        and reporting_grain.subscription_name = subscription_summary.subscription_name
        and reporting_grain.country = subscription_summary.country
        and (reporting_grain.state = subscription_summary.state or (reporting_grain.state is null and subscription_summary.state is null))
    left join subscription_events
        on reporting_grain.date_day = subscription_events.date_day
        and reporting_grain.source_relation = subscription_events.source_relation
        and reporting_grain.account_id =  subscription_events.account_id 
        and reporting_grain.app_name = subscription_events.app_name
        and reporting_grain.subscription_name = subscription_events.subscription_name
        and reporting_grain.country = subscription_events.country
        and (reporting_grain.state = subscription_events.state or (reporting_grain.state is null and subscription_events.state is null))
    left join country_codes
        on reporting_grain.country = country_codes.country_code_alpha_2
    
)

select * 
from joined
