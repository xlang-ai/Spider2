{{ config(materialized='table') }}

with order_line as (

    select *
    from {{ var('shopify_order_line') }}

), tax as (

    select
        *
    from {{ var('shopify_tax_line') }}

), shipping as (

    select
        *
    from {{ ref('int_shopify__order__shipping_aggregates')}}

), tax_aggregates as (

    select
        order_line_id,
        source_relation,
        sum(price) as price

    from tax
    group by 1,2

), order_line_aggregates as (

    select 
        order_line.order_id,
        order_line.source_relation,
        count(*) as line_item_count,
        sum(order_line.quantity) as order_total_quantity,
        sum(tax_aggregates.price) as order_total_tax,
        sum(order_line.total_discount) as order_total_discount

    from order_line
    left join tax_aggregates
        on tax_aggregates.order_line_id = order_line.order_line_id
        and tax_aggregates.source_relation = order_line.source_relation
    group by 1,2

), final as (

    select
        order_line_aggregates.order_id,
        order_line_aggregates.source_relation,
        order_line_aggregates.line_item_count,
        order_line_aggregates.order_total_quantity,
        order_line_aggregates.order_total_tax,
        order_line_aggregates.order_total_discount,
        shipping.shipping_price as order_total_shipping,
        shipping.discounted_shipping_price as order_total_shipping_with_discounts,
        shipping.shipping_tax as order_total_shipping_tax

    from order_line_aggregates
    left join shipping
        on shipping.order_id = order_line_aggregates.order_id
        and shipping.source_relation = order_line_aggregates.source_relation
)

select *
from final