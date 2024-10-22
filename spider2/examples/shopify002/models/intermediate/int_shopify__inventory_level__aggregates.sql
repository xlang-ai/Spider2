with order_lines as (

    select *
    from {{ var('shopify_order_line') }}
),

fulfillment as (

    select *
    from {{ var('shopify_fulfillment') }}
),

orders as (

    select *
    from {{ var('shopify_order') }}
    where not coalesce(is_deleted, false)
), 

refunds as (

    select *
    from {{ ref('shopify__orders__order_refunds') }}

), refunds_aggregated as (
    
    select
        order_line_id,
        source_relation,
        sum(quantity) as quantity,
        sum(coalesce(subtotal, 0)) as subtotal

    from refunds
    group by 1,2
),

joined as (

    select
        order_lines.order_line_id,
        order_lines.variant_id,
        order_lines.source_relation,
        fulfillment.location_id, -- location id is stored in fulfillment rather than order
        orders.order_id,
        orders.customer_id,
        fulfillment.fulfillment_id,
        lower(orders.email) as email,
        order_lines.pre_tax_price,
        order_lines.quantity,
        orders.created_timestamp as order_created_timestamp,
        fulfillment.status as fulfillment_status, 
        refunds_aggregated.subtotal as subtotal_sold_refunds, 
        refunds_aggregated.quantity as quantity_sold_refunds

    from order_lines
    join orders
        on order_lines.order_id = orders.order_id
        and order_lines.source_relation = orders.source_relation
    join fulfillment
        on cast(orders.order_id as string) = cast(fulfillment.order_id as string)
        and orders.source_relation = fulfillment.source_relation
    left join refunds_aggregated
        on refunds_aggregated.order_line_id = order_lines.order_line_id
        and refunds_aggregated.source_relation = order_lines.source_relation
),

aggregated as (

    select
        variant_id,
        location_id,
        source_relation,
        sum(pre_tax_price) as subtotal_sold,
        sum(quantity) as quantity_sold,
        count(distinct order_id) as count_distinct_orders,
        count(distinct customer_id) as count_distinct_customers,
        count(distinct email) as count_distinct_customer_emails,
        min(order_created_timestamp) as first_order_timestamp,
        max(order_created_timestamp) as last_order_timestamp

        {% for status in ['pending', 'open', 'success', 'cancelled', 'error', 'failure'] %}
        , count(distinct case when fulfillment_status = '{{ status }}' then fulfillment_id end) as count_fulfillment_{{ status }}
        {% endfor %}

        , sum(coalesce(subtotal_sold_refunds, 0)) as subtotal_sold_refunds
        , sum(coalesce(quantity_sold_refunds, 0)) as quantity_sold_refunds

    from joined

    {{ dbt_utils.group_by(n=3) }}
)

select *
from aggregated