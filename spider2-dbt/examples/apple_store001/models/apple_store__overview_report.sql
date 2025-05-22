with app as (

    select * 
    from {{ var('app') }}
),

app_store as (

    select *
    from {{ ref('int_apple_store__app_store_overview') }}
),

crashes as (

    select *
    from {{ ref('int_apple_store__crashes_overview') }}
),

downloads as (

    select *
    from {{ ref('int_apple_store__downloads_overview') }}
),

{% if var('apple_store__using_subscriptions', False) %}
subscriptions as (

    select *
    from {{ ref('int_apple_store__sales_subscription_overview') }}
), 
{% endif %}

usage as (

    select *
    from {{ ref('int_apple_store__usage_overview') }}
),

reporting_grain as (

    select distinct
        source_relation,
        date_day,
        app_id 
    from app_store
), 

joined as (

    select 
        reporting_grain.source_relation,
        reporting_grain.date_day,
        reporting_grain.app_id,
        app.app_name,
        coalesce(app_store.impressions, 0) as impressions,
        coalesce(app_store.page_views, 0) as page_views,
        coalesce(crashes.crashes,0) as crashes,
        coalesce(downloads.first_time_downloads, 0) as first_time_downloads,
        coalesce(downloads.redownloads, 0) as redownloads,
        coalesce(downloads.total_downloads, 0) as total_downloads,
        coalesce(usage.active_devices, 0) as active_devices,
        coalesce(usage.deletions, 0) as deletions,
        coalesce(usage.installations, 0) as installations,
        coalesce(usage.sessions, 0) as sessions
        {% if var('apple_store__using_subscriptions', False) %}
        ,
        coalesce(subscriptions.active_free_trial_introductory_offer_subscriptions, 0) as active_free_trial_introductory_offer_subscriptions,
        coalesce(subscriptions.active_pay_as_you_go_introductory_offer_subscriptions, 0) as active_pay_as_you_go_introductory_offer_subscriptions,
        coalesce(subscriptions.active_pay_up_front_introductory_offer_subscriptions, 0) as active_pay_up_front_introductory_offer_subscriptions,
        coalesce(subscriptions.active_standard_price_subscriptions, 0) as active_standard_price_subscriptions
        {% for event_val in var('apple_store__subscription_events') %}
        {% set event_column = 'event_' ~ event_val | replace(' ', '_') | trim | lower %}
        , coalesce({{ 'subscriptions.' ~ event_column }}, 0)
            as {{ event_column }} 
        {% endfor %}
        {% endif %}
    from reporting_grain
    left join app 
        on reporting_grain.app_id = app.app_id
        and reporting_grain.source_relation = app.source_relation
    left join app_store 
        on reporting_grain.date_day = app_store.date_day
        and reporting_grain.source_relation = app_store.source_relation
        and reporting_grain.app_id = app_store.app_id
    left join crashes
        on reporting_grain.date_day = crashes.date_day
        and reporting_grain.source_relation = crashes.source_relation
        and reporting_grain.app_id = crashes.app_id
    left join downloads
        on reporting_grain.date_day = downloads.date_day
        and reporting_grain.source_relation = downloads.source_relation
        and reporting_grain.app_id = downloads.app_id
    {% if var('apple_store__using_subscriptions', False) %}
    left join subscriptions 
        on reporting_grain.date_day = subscriptions.date_day
        and reporting_grain.source_relation = subscriptions.source_relation
        and reporting_grain.app_id = subscriptions.app_id
    {% endif %}
    left join usage
        on reporting_grain.date_day = usage.date_day
        and reporting_grain.source_relation = usage.source_relation
        and reporting_grain.app_id = usage.app_id        
)

select * 
from joined