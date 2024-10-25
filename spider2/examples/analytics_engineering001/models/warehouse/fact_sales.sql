{{ config(
    partition_by={
        "field": "order_date",
        "data_type": "date"
    }
) }}

WITH source AS (
    SELECT
        od.order_id,
        od.product_id,
        o.customer_id,
        o.employee_id,
        o.shipper_id,
        od.quantity,
        od.unit_price,
        od.discount,
        od.status_id,
        od.date_allocated,
        od.purchase_order_id,
        od.inventory_id,
        CAST(STRPTIME(o.order_date, '%m/%d/%Y %H:%M:%S') AS DATE) AS order_date,
        o.shipped_date,
        o.paid_date,
        get_current_timestamp() AS insertion_timestamp
    FROM {{ ref('stg_orders') }} o
    LEFT JOIN {{ ref('stg_order_details') }} od
    ON od.order_id = o.id
    WHERE od.order_id IS NOT NULL
),

unique_source AS (
    SELECT *,
           ROW_NUMBER() OVER(PARTITION BY customer_id, employee_id, order_id, product_id, shipper_id, purchase_order_id, order_date ORDER BY order_id) AS row_number
    FROM source
)

SELECT
    order_id,
    product_id,
    customer_id,
    employee_id,
    shipper_id,
    quantity,
    unit_price,
    discount,
    status_id,
    date_allocated,
    purchase_order_id,
    inventory_id,
    order_date,
    shipped_date,
    paid_date,
    insertion_timestamp
FROM unique_source
WHERE row_number = 1
