WITH source AS (
    SELECT
        p.product_id,
        p.product_code,
        p.product_name,
        p.description,
        p.supplier_company,
        p.standard_cost,
        p.list_price,
        p.reorder_level,
        p.target_level,
        p.quantity_per_unit,
        p.discontinued,
        p.minimum_reorder_quantity,
        p.category,
        i.inventory_id,
        i.transaction_type,
        i.transaction_created_date,
        i.transaction_modified_date,
        i.product_id AS ipd,
        i.quantity,
        i.purchase_order_id,
        i.customer_order_id,
        i.comments,
        get_current_timestamp() AS insertion_timestamp,
FROM {{ ref('fact_inventory') }} i
LEFT JOIN {{ ref('dim_products') }} p
ON p.product_id = i.product_id
)

SELECT *
FROM source