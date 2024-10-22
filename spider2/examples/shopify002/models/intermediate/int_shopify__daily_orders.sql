with orders as (

    select *
    from {{ ref('shopify__orders') }}

    where not coalesce(is_deleted, false)
),

order_lines as(

    select *
    from {{ ref('shopify__order_lines') }}
),

order_aggregates as (

    select
        source_relation,
        cast({{ dbt.date_trunc('day','created_timestamp') }} as date) as date_day,
        count(distinct order_id) as count_orders,
        sum(line_item_count) as count_line_items,
        avg(line_item_count) as avg_line_item_count,
        count(distinct customer_id) as count_customers,
        count(distinct email) as count_customer_emails,
        sum(order_adjusted_total) as order_adjusted_total,
        avg(order_adjusted_total) as avg_order_value,
        sum(shipping_cost) as shipping_cost,
        sum(order_adjustment_amount) as order_adjustment_amount,
        sum(order_adjustment_tax_amount) as order_adjustment_tax_amount,
        sum(refund_subtotal) as refund_subtotal,
        sum(refund_total_tax) as refund_total_tax,
        sum(total_discounts) as total_discounts,
        avg(total_discounts) as avg_discount,
        sum(shipping_discount_amount) as shipping_discount_amount,
        avg(shipping_discount_amount) as avg_shipping_discount_amount,
        sum(percentage_calc_discount_amount) as percentage_calc_discount_amount,
        avg(percentage_calc_discount_amount) as avg_percentage_calc_discount_amount,
        sum(fixed_amount_discount_amount) as fixed_amount_discount_amount,
        avg(fixed_amount_discount_amount) as avg_fixed_amount_discount_amount,
        sum(count_discount_codes_applied) as count_discount_codes_applied,
        count(distinct location_id) as count_locations_ordered_from,
        sum(case when count_discount_codes_applied > 0 then 1 else 0 end) as count_orders_with_discounts,
        sum(case when refund_subtotal > 0 then 1 else 0 end) as count_orders_with_refunds,
        min(created_timestamp) as first_order_timestamp,
        max(created_timestamp) as last_order_timestamp

    from orders
    group by 1,2

),

order_line_aggregates as (

    select
        order_lines.source_relation,
        cast({{ dbt.date_trunc('day','orders.created_timestamp') }} as date) as date_day,
        sum(order_lines.quantity) as quantity_sold,
        sum(order_lines.refunded_quantity) as quantity_refunded,
        sum(order_lines.quantity_net_refunds) as quantity_net,
        sum(order_lines.quantity) / count(distinct order_lines.order_id) as avg_quantity_sold,
        sum(order_lines.quantity_net_refunds) / count(distinct order_lines.order_id) as avg_quantity_net,
        count(distinct order_lines.variant_id) as count_variants_sold, 
        count(distinct order_lines.product_id) as count_products_sold, 
        sum(case when order_lines.is_gift_card then order_lines.quantity_net_refunds else 0 end) as quantity_gift_cards_sold,
        sum(case when order_lines.is_shipping_required then order_lines.quantity_net_refunds else 0 end) as quantity_requiring_shipping

    from order_lines
    left join orders -- just joining with order to get the created_timestamp
        on order_lines.order_id = orders.order_id
        and order_lines.source_relation = orders.source_relation

    group by 1,2
),

final as (

    select 
        order_aggregates.*,
        order_line_aggregates.quantity_sold,
        order_line_aggregates.quantity_refunded,
        order_line_aggregates.quantity_net,
        order_line_aggregates.count_variants_sold,
        order_line_aggregates.count_products_sold,
        order_line_aggregates.quantity_gift_cards_sold,
        order_line_aggregates.quantity_requiring_shipping,
        order_line_aggregates.avg_quantity_sold,
        order_line_aggregates.avg_quantity_net

    from order_aggregates
    left join order_line_aggregates
        on order_aggregates.date_day = order_line_aggregates.date_day
        and order_aggregates.source_relation = order_line_aggregates.source_relation
)

select *
from final