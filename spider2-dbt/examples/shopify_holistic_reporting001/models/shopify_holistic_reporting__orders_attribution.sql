{{
    config(
        materialized='table',
        unique_key='unique_order_key',
        partition_by={
            "field": "created_timestamp",
            "data_type": "timestamp"
        } if target.type == 'bigquery' else none,
        incremental_strategy = 'delete+insert',
        file_format = 'delta'
    )
}}

with orders as (

    select *
    from {{ ref('shopify__orders') }}

    -- just grab new + newly updated orders
    {% if is_incremental() %}
        where updated_timestamp >= (select max(updated_timestamp) from {{ this }})
    {% endif %}

), events as (

    select 
        *
    from {{ ref('klaviyo__events') }}

    where 
        coalesce(last_touch_campaign_id, last_touch_flow_id) is not null
    {% if var('klaviyo__eligible_attribution_events') != [] %}
        and lower(type) in {{ "('" ~ (var('klaviyo__eligible_attribution_events') | join("', '")) ~ "')" }}
    {% endif %}

    -- only grab the events for users who are in the new increment of orders
    {% if is_incremental() %}
        and lower(person_email) in (select distinct lower(email) from orders)
    {% endif %}

), join_orders_w_events as (

    select 
        orders.*,
        events.last_touch_campaign_id,
        events.last_touch_flow_id,
        events.variation_id as last_touch_variation_id,
        events.campaign_name as last_touch_campaign_name,
        events.campaign_subject_line as last_touch_campaign_subject_line,
        events.flow_name as last_touch_flow_name,
        events.campaign_type as last_touch_campaign_type,
        events.event_id as last_touch_event_id,
        events.occurred_at as last_touch_event_occurred_at,
        events.type as last_touch_event_type,
        events.integration_id as last_touch_integration_id,
        events.integration_name as last_touch_integration_name,
        events.integration_category as last_touch_integration_category,
        events.source_relation as klaviyo_source_relation

    from orders 
    left join events on 
        lower(orders.email) = lower(events.person_email)
        and {{ dbt.datediff('events.occurred_at', 'orders.created_timestamp', 'hour') }} <= (
            case when events.type like '%sms%' then {{ var('klaviyo__sms_attribution_lookback') }}
            else {{ var('klaviyo__email_attribution_lookback') }} end)
        and orders.created_timestamp > events.occurred_at

), order_events as (

    select
        *,
        row_number() over (partition by order_id order by last_touch_event_occurred_at desc) as event_index,

        -- the order was made after X interactions with campaign/flow
        count(last_touch_event_id) over (partition by order_id, last_touch_campaign_id) as count_interactions_with_campaign,
        count(last_touch_event_id) over (partition by order_id, last_touch_flow_id) as count_interactions_with_flow


    from join_orders_w_events

), last_touches as (

    select 
        {{ dbt_utils.star(from=ref('shopify__orders'), except=['source_relation']) }},
        last_touch_campaign_id is not null or last_touch_flow_id is not null as is_attributed,
        last_touch_campaign_id,
        last_touch_flow_id,
        last_touch_variation_id,
        last_touch_campaign_name,
        last_touch_campaign_subject_line,
        last_touch_campaign_type,
        last_touch_flow_name,
        case when last_touch_campaign_id is not null then count_interactions_with_campaign else null end as count_interactions_with_campaign, -- will be null if it's associated with a flow
        count_interactions_with_flow, -- will be null if it's associated with a campaign
        last_touch_event_id,
        last_touch_event_occurred_at,
        last_touch_event_type,
        last_touch_integration_name,
        last_touch_integration_category,
        source_relation as shopify_source_relation,
        klaviyo_source_relation,
        {{ dbt_utils.generate_surrogate_key(['order_id', 'source_relation']) }} as unique_order_key

    from order_events
    where event_index = 1
)

select *
from last_touches