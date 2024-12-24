WITH february_orders AS (
    SELECT
        h."hub_name" AS hub_name,
        COUNT(*) AS orders_february
    FROM 
        DELIVERY_CENTER.DELIVERY_CENTER.ORDERS o 
    LEFT JOIN
        DELIVERY_CENTER.DELIVERY_CENTER.STORES s ON o."store_id" = s."store_id" 
    LEFT JOIN 
        DELIVERY_CENTER.DELIVERY_CENTER.HUBS h ON s."hub_id" = h."hub_id" 
    WHERE o."order_created_month" = 2 AND o."order_status" = 'FINISHED'
    GROUP BY
        h."hub_name"
),
march_orders AS (
    SELECT
        h."hub_name" AS hub_name,
        COUNT(*) AS orders_march
    FROM 
        DELIVERY_CENTER.DELIVERY_CENTER.ORDERS o 
    LEFT JOIN
        DELIVERY_CENTER.DELIVERY_CENTER.STORES s ON o."store_id" = s."store_id" 
    LEFT JOIN 
        DELIVERY_CENTER.DELIVERY_CENTER.HUBS h ON s."hub_id" = h."hub_id" 
    WHERE o."order_created_month" = 3 AND o."order_status" = 'FINISHED'
    GROUP BY
        h."hub_name"
)
SELECT
    fo.hub_name
FROM
    february_orders fo
LEFT JOIN 
    march_orders mo ON fo.hub_name = mo.hub_name
WHERE 
    fo.orders_february > 0 AND 
    mo.orders_march > 0 AND
    (CAST((mo.orders_march - fo.orders_february) AS REAL) / CAST(fo.orders_february AS REAL)) > 0.2
