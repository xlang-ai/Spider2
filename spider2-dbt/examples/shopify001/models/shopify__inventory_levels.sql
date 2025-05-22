with inventory_level as (

    select *
    from {{ var('shopify_inventory_level') }}
), 

inventory_item as (

    select *
    from {{ var('shopify_inventory_item') }}
),

location as (

    select *
    from {{ var('shopify_location') }}
),

product_variant as (

    select *
    from {{ var('shopify_product_variant') }}
),

product as (

    select *
    from {{ var('shopify_product') }}
),

inventory_level_aggregated as (

    select *
    from {{ ref('int_shopify__inventory_level__aggregates') }}
),

joined_info as (

    select 
        inventory_level.*,
        inventory_item.sku,
        inventory_item.is_deleted as is_inventory_item_deleted,
        inventory_item.cost,
        inventory_item.country_code_of_origin,
        inventory_item.province_code_of_origin,
        inventory_item.is_shipping_required,
        inventory_item.is_inventory_quantity_tracked,
        inventory_item.created_at as inventory_item_created_at,
        inventory_item.updated_at as inventory_item_updated_at,

        location.name as location_name, 
        location.is_deleted as is_location_deleted,
        location.is_active as is_location_active,
        location.address_1,
        location.address_2,
        location.city,
        location.country,
        location.country_code,
        location.is_legacy as is_legacy_location,
        location.province,
        location.province_code,
        location.phone,
        location.zip,
        location.created_at as location_created_at,
        location.updated_at as location_updated_at,

        product_variant.variant_id,
        product_variant.product_id,
        product_variant.title as variant_title,
        product_variant.inventory_policy as variant_inventory_policy,
        product_variant.price as variant_price,
        product_variant.image_id as variant_image_id,
        product_variant.fulfillment_service as variant_fulfillment_service,
        product_variant.inventory_management as variant_inventory_management,
        product_variant.is_taxable as is_variant_taxable,
        product_variant.barcode as variant_barcode,
        product_variant.grams as variant_grams, 
        product_variant.inventory_quantity as variant_inventory_quantity,
        product_variant.weight as variant_weight,
        product_variant.weight_unit as variant_weight_unit,
        product_variant.option_1 as variant_option_1,
        product_variant.option_2 as variant_option_2,
        product_variant.option_3 as variant_option_3,
        product_variant.tax_code as variant_tax_code,
        product_variant.created_timestamp as variant_created_at,
        product_variant.updated_timestamp as variant_updated_at

        {{ fivetran_utils.persist_pass_through_columns('product_variant_pass_through_columns', identifier='product_variant') }}

    from inventory_level
    join inventory_item 
        on inventory_level.inventory_item_id = inventory_item.inventory_item_id 
        and inventory_level.source_relation = inventory_item.source_relation 
    join location 
        on inventory_level.location_id = location.location_id 
        and inventory_level.source_relation = location.source_relation 
    join product_variant 
        on inventory_item.inventory_item_id = product_variant.inventory_item_id 
        and inventory_item.source_relation = product_variant.source_relation

),

joined_aggregates as (

    select 
        joined_info.*,
        coalesce(inventory_level_aggregated.subtotal_sold, 0) as subtotal_sold,
        coalesce(inventory_level_aggregated.quantity_sold, 0) as quantity_sold,
        coalesce(inventory_level_aggregated.count_distinct_orders, 0) as count_distinct_orders,
        coalesce(inventory_level_aggregated.count_distinct_customers, 0) as count_distinct_customers,
        coalesce(inventory_level_aggregated.count_distinct_customer_emails, 0) as count_distinct_customer_emails,
        inventory_level_aggregated.first_order_timestamp,
        inventory_level_aggregated.last_order_timestamp,
        coalesce(inventory_level_aggregated.subtotal_sold_refunds, 0) as subtotal_sold_refunds,
        coalesce(inventory_level_aggregated.quantity_sold_refunds, 0) as quantity_sold_refunds

        {% for status in ['pending', 'open', 'success', 'cancelled', 'error', 'failure'] %}
        , coalesce(count_fulfillment_{{ status }}, 0) as count_fulfillment_{{ status }}
        {% endfor %}

    from joined_info
    left join inventory_level_aggregated
        on joined_info.location_id = inventory_level_aggregated.location_id
        and joined_info.variant_id = inventory_level_aggregated.variant_id
        and joined_info.source_relation = inventory_level_aggregated.source_relation
),

final as (

    select 
        *,
        subtotal_sold - subtotal_sold_refunds as net_subtotal_sold,
        quantity_sold - quantity_sold_refunds as net_quantity_sold
    from joined_aggregates
)

select * 
from final