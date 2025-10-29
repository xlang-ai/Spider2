WITH "top_store" AS (
    SELECT
        o."store_id"
    FROM "DELIVERY_CENTER"."DELIVERY_CENTER"."ORDERS" o
    GROUP BY o."store_id"
    ORDER BY COUNT(*) DESC, o."store_id"
    FETCH FIRST 1 ROW ONLY
)
SELECT
    ts."store_id",
    s."store_name",
    COUNT(*) AS "total_orders",
    SUM(
        CASE
            WHEN EXISTS (
                SELECT 1
                FROM "DELIVERY_CENTER"."DELIVERY_CENTER"."DELIVERIES" d
                WHERE d."delivery_order_id" = o."delivery_order_id"
                  AND d."delivery_status" = 'DELIVERED'
            ) THEN 1
            ELSE 0
        END
    ) AS "delivered_orders",
    SUM(
        CASE
            WHEN EXISTS (
                SELECT 1
                FROM "DELIVERY_CENTER"."DELIVERY_CENTER"."DELIVERIES" d
                WHERE d."delivery_order_id" = o."delivery_order_id"
                  AND d."delivery_status" = 'DELIVERED'
            ) THEN 1
            ELSE 0
        END
    )::FLOAT / COUNT(*) AS "delivered_ratio"
FROM "DELIVERY_CENTER"."DELIVERY_CENTER"."ORDERS" o
JOIN "top_store" ts
    ON o."store_id" = ts."store_id"
JOIN "DELIVERY_CENTER"."DELIVERY_CENTER"."STORES" s
    ON s."store_id" = ts."store_id"
GROUP BY
    ts."store_id",
    s."store_name";