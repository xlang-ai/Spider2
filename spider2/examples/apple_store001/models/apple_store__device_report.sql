with app as (

    select * 
    from {{ var('app') }}
),

app_store_device as (

    select *
    from {{ var('app_store_device') }}
),

downloads_device as (

    select *
    from {{ var('downloads_device') }}
),

usage_device as (

    select *
    from {{ var('usage_device') }}
),

crashes_device as (

    select *
    from {{ ref('int_apple_store__crashes_device') }}
),

{% if var('apple_store__using_subscriptions', False) %}
subscription_device as (

    select *
    from {{ ref('int_apple_store__subscription_device') }}
),
{% endif %}

reporting_grain_combined as (

    select
        source_relation,
        date_day,
        app_id,
        source_type,
        device 
    from app_store_device
    union all
    select
        source_relation,
        date_day,
        app_id,
        source_type,
        device
    from crashes_device
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
        reporting_grain.app_id, 
        app.app_name,
        reporting_grain.source_type,
        reporting_grain.device,
        coalesce(app_store_device.impressions, 0) as impressions,
        coalesce(app_store_device.impressions_unique_device, 0) as impressions_unique_device,
        coalesce(app_store_device.page_views, 0) as page_views,
        coalesce(app_store_device.page_views_unique_device, 0) as page_views_unique_device,
        coalesce(crashes_device.crashes, 0) as crashes,
        coalesce(downloads_device.first_time_downloads, 0) as first_time_downloads,
        coalesce(downloads_device.redownloads, 0) as redownloads,
        coalesce(downloads_device.total_downloads, 0) as total_downloads,
        coalesce(usage_device.active_devices, 0) as active_devices,
        coalesce(usage_device.active_devices_last_30_days, 0) as active_devices_last_30_days,
        coalesce(usage_device.deletions, 0) as deletions,
        coalesce(usage_device.installations, 0) as installations,
        coalesce(usage_device.sessions, 0) as sessions
        {% if var('apple_store__using_subscriptions', False) %}
        ,
        coalesce(subscription_device.active_free_trial_introductory_offer_subscriptions, 0) as active_free_trial_introductory_offer_subscriptions,
        coalesce(subscription_device.active_pay_as_you_go_introductory_offer_subscriptions, 0) as active_pay_a_you_go_introductory_offer_subscriptions,
        coalesce(subscription_device.active_pay_up_front_introductory_offer_subscriptions, 0) as active_pay_up_front_introductory_offer_subscriptions,
        coalesce(subscription_device.active_standard_price_subscriptions, 0) as active_standard_price_subscriptions
        {% for event_val in var('apple_store__subscription_events') %}
        {% set event_column = 'event_' ~ event_val | replace(' ', '_') | trim | lower %}
        , coalesce({{ 'subscription_device.' ~ event_column }}, 0)
            as {{ event_column }} 
        {% endfor %}
        {% endif %}
    from reporting_grain
    left join app 
        on reporting_grain.app_id = app.app_id
        and reporting_grain.source_relation = app.source_relation
    left join app_store_device 
        on reporting_grain.date_day = app_store_device.date_day
        and reporting_grain.source_relation = app_store_device.source_relation
        and reporting_grain.app_id = app_store_device.app_id 
        and reporting_grain.source_type = app_store_device.source_type
        and reporting_grain.device = app_store_device.device
    left join crashes_device
        on reporting_grain.date_day = crashes_device.date_day
        and reporting_grain.source_relation = crashes_device.source_relation
        and reporting_grain.app_id = crashes_device.app_id
        and reporting_grain.source_type = crashes_device.source_type
        and reporting_grain.device = crashes_device.device
    left join downloads_device
        on reporting_grain.date_day = downloads_device.date_day
        and reporting_grain.source_relation = downloads_device.source_relation
        and reporting_grain.app_id = downloads_device.app_id 
        and reporting_grain.source_type = downloads_device.source_type
        and reporting_grain.device = downloads_device.device
    {% if var('apple_store__using_subscriptions', False) %}
    left join subscription_device
        on reporting_grain.date_day = subscription_device.date_day
        and reporting_grain.source_relation = subscription_device.source_relation
        and reporting_grain.app_id = subscription_device.app_id 
        and reporting_grain.source_type = subscription_device.source_type
        and reporting_grain.device = subscription_device.device
    {% endif %}
    left join usage_device
        on reporting_grain.date_day = usage_device.date_day
        and reporting_grain.source_relation = usage_device.source_relation
        and reporting_grain.app_id = usage_device.app_id 
        and reporting_grain.source_type = usage_device.source_type
        and reporting_grain.device = usage_device.device
)

select * 
from joined