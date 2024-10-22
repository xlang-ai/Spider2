{{ config(enabled=var('apple_store__using_subscriptions', False)) }}

with subscription_summary as (

    select
        source_relation,
        date_day,
        app_id,
        sum(active_free_trial_introductory_offer_subscriptions) as active_free_trial_introductory_offer_subscriptions,
        sum(active_pay_as_you_go_introductory_offer_subscriptions) as active_pay_as_you_go_introductory_offer_subscriptions,
        sum(active_pay_up_front_introductory_offer_subscriptions) as active_pay_up_front_introductory_offer_subscriptions,
        sum(active_standard_price_subscriptions) as active_standard_price_subscriptions
    from {{ ref('int_apple_store__sales_subscription_summary') }}
    {{ dbt_utils.group_by(3) }}
), 

subscription_events as (

    select 
        source_relation,
        date_day,
        app_id
        {% for event_val in var('apple_store__subscription_events') %}
        {% set event_column = 'event_' ~ event_val | replace(' ', '_') | trim | lower %}
        , coalesce(sum({{event_column }}), 0)
            as {{ event_column }} 
        {% endfor %}
    from {{ ref('int_apple_store__sales_subscription_events') }}
    {{ dbt_utils.group_by(3) }}
), 

joined as (

    select 
        subscription_events.*,
        active_free_trial_introductory_offer_subscriptions,
        active_pay_as_you_go_introductory_offer_subscriptions,
        active_pay_up_front_introductory_offer_subscriptions,
        active_standard_price_subscriptions
    from subscription_summary 
    left join subscription_events
        on subscription_summary.date_day = subscription_events.date_day
        and subscription_summary.source_relation = subscription_events.source_relation
        and subscription_summary.app_id = subscription_events.app_id 
)

select * 
from joined