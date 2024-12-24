WITH CustomerData AS (
    SELECT
        "customer_unique_id",
        COUNT(DISTINCT E_COMMERCE.E_COMMERCE.ORDERS."order_id") AS order_count,
        SUM(TO_NUMBER("payment_value")) AS total_payment,
        DATE_PART('day', MIN(TO_TIMESTAMP("order_purchase_timestamp", 'YYYY-MM-DD HH24:MI:SS'))) AS first_order_day,
        DATE_PART('day', MAX(TO_TIMESTAMP("order_purchase_timestamp", 'YYYY-MM-DD HH24:MI:SS'))) AS last_order_day
    FROM E_COMMERCE.E_COMMERCE.CUSTOMERS 
        JOIN E_COMMERCE.E_COMMERCE.ORDERS USING ("customer_id")
        JOIN E_COMMERCE.E_COMMERCE.ORDER_PAYMENTS USING ("order_id")
    GROUP BY "customer_unique_id"
)
SELECT
    "customer_unique_id",
    order_count AS PF,
    ROUND(total_payment / order_count, 2) AS AOV,
    CASE
        WHEN (last_order_day - first_order_day) < 7 THEN
            1
        ELSE
            (last_order_day - first_order_day) / 7
        END AS ACL
FROM CustomerData
ORDER BY AOV DESC
LIMIT 3;