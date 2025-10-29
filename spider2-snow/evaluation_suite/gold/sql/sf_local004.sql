WITH OrderTotalPayments AS (
    SELECT
        "order_id",
        SUM("payment_value") AS "total_payment"
    FROM "E_COMMERCE"."E_COMMERCE"."ORDER_PAYMENTS"
    GROUP BY "order_id"
)
SELECT
    C."customer_unique_id",
    COUNT(O."order_id") AS "number_of_orders",
    AVG(OTP."total_payment") AS "average_payment_per_order",
    CASE
        WHEN DATEDIFF('day', MIN(TO_TIMESTAMP(O."order_purchase_timestamp")), MAX(TO_TIMESTAMP(O."order_purchase_timestamp"))) < 7
        THEN 1.0
        ELSE DATEDIFF('day', MIN(TO_TIMESTAMP(O."order_purchase_timestamp")), MAX(TO_TIMESTAMP(O."order_purchase_timestamp"))) / 7.0
    END AS "customer_lifespan_in_weeks"
FROM "E_COMMERCE"."E_COMMERCE"."CUSTOMERS" AS C
JOIN "E_COMMERCE"."E_COMMERCE"."ORDERS" AS O ON C."customer_id" = O."customer_id"
JOIN OrderTotalPayments AS OTP ON O."order_id" = OTP."order_id"
GROUP BY C."customer_unique_id"
ORDER BY "average_payment_per_order" DESC
LIMIT 3;