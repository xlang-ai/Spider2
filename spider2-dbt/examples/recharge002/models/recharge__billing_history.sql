with orders as (
    select *
    from {{ var('order') }}

), order_line_items as (
    select 
        order_id,
        sum(quantity) as order_item_quantity,
        round(cast(sum(total_price) as {{ dbt.type_numeric() }}), 2) as order_line_item_total
    from {{ var('order_line_item') }}
    group by 1


), charges as ( --each charge can have multiple orders associated with it
    select *
    from {{ var('charge') }}

), charge_shipping_lines as (
    select 
        charge_id,
        round(cast(sum(price) as {{ dbt.type_numeric() }}), 2) as total_shipping
    from {{ var('charge_shipping_line') }}
    group by 1

), charges_enriched as (
    select
        charges.*,
        charge_shipping_lines.total_shipping
    from charges
    left join charge_shipping_lines
        on charge_shipping_lines.charge_id = charges.charge_id

), joined as (
    select 
        orders.*,
        -- recognized_total (calculated total based on prepaid subscriptions)
        charges_enriched.charge_created_at,
        charges_enriched.payment_processor,
        charges_enriched.tags,
        charges_enriched.orders_count,
        charges_enriched.charge_type,
        {% set agg_cols = ['total_price', 'subtotal_price', 'tax_lines', 'total_discounts', 
            'total_refunds', 'total_tax', 'total_weight_grams', 'total_shipping'] %}
        {% for col in agg_cols %}
            -- when several prepaid orders are generated from a single charge, we only want to show total aggregates from the charge on the first instance.
            case when orders.is_prepaid = true then 0 
                else coalesce(charges_enriched.{{ col }}, 0)
                end as charge_{{ col }},
            -- this divides a charge over all the related orders.
            coalesce(round(cast({{ dbt_utils.safe_divide('charges_enriched.' ~ col, 
                'charges_enriched.orders_count') }} as {{ dbt.type_numeric() }}), 2), 0)
                as calculated_order_{{ col }},
        {% endfor %}
        coalesce(order_line_items.order_item_quantity, 0) as order_item_quantity,
        coalesce(order_line_items.order_line_item_total, 0) as order_line_item_total
    from orders
    left join order_line_items
        on order_line_items.order_id = orders.order_id
    left join charges_enriched -- still want to capture charges that don't have an order yet
        on charges_enriched.charge_id = orders.charge_id

), joined_enriched as (
    select 
        joined.*,
        -- total_price includes taxes and discounts, so only need to subtract total_refunds to get net.
        charge_total_price - charge_total_refunds as total_net_charge_value,
        calculated_order_total_price - calculated_order_total_refunds as total_calculated_net_order_value  
    from joined
)

select * 
from joined_enriched