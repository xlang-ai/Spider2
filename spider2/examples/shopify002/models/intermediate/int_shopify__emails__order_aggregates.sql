with orders as (

    select *
    from {{ var('shopify_order') }}

), order_aggregates as (

    select *
    from {{ ref('shopify__orders__order_line_aggregates') }}

), transactions as (

    select *
    from {{ ref('shopify__transactions')}}

    where lower(status) = 'success'
    and lower(kind) not in ('authorization', 'void')
    and lower(gateway) != 'gift_card' -- redeeming a giftcard does not introduce new revenue

), transaction_aggregates as (
    -- this is necessary as customers can pay via multiple payment gateways
    select 
        order_id,
        source_relation,
        lower(kind) as kind,
        sum(currency_exchange_calculated_amount) as currency_exchange_calculated_amount
    from transactions
    group by order_id, source_relation, lower(kind)

), customer_emails as (
-- in case any orders records don't have the customer email attached yet
    select 
        customer_id, 
        source_relation,
        email

    from {{ var('shopify_customer') }}
    where email is not null
    {{ dbt_utils.group_by(n=3) }}
    
), aggregated as (

    select
        lower(customer_emails.email) as email,
        orders.source_relation,
        min(orders.created_timestamp) as first_order_timestamp,
        max(orders.created_timestamp) as most_recent_order_timestamp,
        avg(transaction_aggregates.currency_exchange_calculated_amount) as avg_order_value,
        sum(transaction_aggregates.currency_exchange_calculated_amount) as lifetime_total_spent,
        sum(refunds.currency_exchange_calculated_amount) as lifetime_total_refunded,
        count(distinct orders.order_id) as lifetime_count_orders,
        avg(order_aggregates.order_total_quantity) as avg_quantity_per_order,
        sum(order_aggregates.order_total_tax) as lifetime_total_tax,
        avg(order_aggregates.order_total_tax) as avg_tax_per_order,
        sum(order_aggregates.order_total_discount) as lifetime_total_discount,
        avg(order_aggregates.order_total_discount) as avg_discount_per_order,
        sum(order_aggregates.order_total_shipping) as lifetime_total_shipping,
        avg(order_aggregates.order_total_shipping) as avg_shipping_per_order,
        sum(order_aggregates.order_total_shipping_with_discounts) as lifetime_total_shipping_with_discounts,
        avg(order_aggregates.order_total_shipping_with_discounts) as avg_shipping_with_discounts_per_order,
        sum(order_aggregates.order_total_shipping_tax) as lifetime_total_shipping_tax,
        avg(order_aggregates.order_total_shipping_tax) as avg_shipping_tax_per_order
    from orders
    join customer_emails
        on orders.customer_id = customer_emails.customer_id
        and orders.source_relation = customer_emails.source_relation
    left join transaction_aggregates 
        on orders.order_id = transaction_aggregates.order_id
        and orders.source_relation = transaction_aggregates.source_relation
        and transaction_aggregates.kind in ('sale','capture')
    left join transaction_aggregates as refunds
        on orders.order_id = refunds.order_id
        and orders.source_relation = refunds.source_relation
        and refunds.kind = 'refund'
    left join order_aggregates
        on orders.order_id = order_aggregates.order_id
        and orders.source_relation = order_aggregates.source_relation

    group by 1,2

)

select *
from aggregated