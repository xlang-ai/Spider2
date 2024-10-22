with subscriptions as (

    select * 
    from {{ var('subscription_history') }}
    where is_most_recent_record

), charges as (
    select * 
    from {{ var('charge') }}
    where lower(charge_type) = 'recurring'

), charge_line_items as (
    select * 
    from {{ var('charge_line_item') }}

), customers_charge_lines as (
    select 
        charge_line_items.charge_id,
        charge_line_items.purchase_item_id,
        charge_line_items.external_product_id_ecommerce,
        charge_line_items.external_variant_id_ecommerce,
        charges.customer_id,
        charges.address_id,
        charges.charge_created_at,
        charges.charge_status
    from charge_line_items
    left join charges
        on charges.charge_id = charge_line_items.charge_id

), subscriptions_charges as (
    select 
        subscriptions.subscription_id,
        count(case when lower(customers_charge_lines.charge_status) = 'success' 
            then 1 else null
            end) as count_successful_charges,
        count(case when lower(customers_charge_lines.charge_status) = 'queued' 
            then 1 else null
            end) as count_queued_charges
    from subscriptions
    left join customers_charge_lines
        on customers_charge_lines.purchase_item_id = subscriptions.subscription_id
    group by 1

), subscriptions_enriched as (
    select
        subscriptions.*,
        subscriptions_charges.count_successful_charges,
        subscriptions_charges.count_queued_charges,
        case when subscription_next_charge_scheduled_at is null then null
            when expire_after_specific_number_of_charges - count_successful_charges < 0 then null
            else expire_after_specific_number_of_charges - count_successful_charges
            end as charges_until_expiration,
        case when lower(order_interval_unit) = 'month' then charge_interval_frequency * 30
            when lower(order_interval_unit) = 'week' then charge_interval_frequency * 7
            else charge_interval_frequency 
            end as charge_interval_frequency_days
    from subscriptions
    left join subscriptions_charges
        on subscriptions_charges.subscription_id = subscriptions.subscription_id
)

select * 
from subscriptions_enriched