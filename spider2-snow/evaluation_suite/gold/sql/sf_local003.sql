WITH RecencyScore AS (
    SELECT "customer_unique_id",
           MAX("order_purchase_timestamp") AS "last_purchase",
           NTILE(5) OVER (ORDER BY MAX("order_purchase_timestamp") DESC) AS "recency"
    FROM E_COMMERCE.E_COMMERCE.ORDERS
        JOIN E_COMMERCE.E_COMMERCE.CUSTOMERS USING ("customer_id")
    WHERE "order_status" = 'delivered'
    GROUP BY "customer_unique_id"
),
FrequencyScore AS (
    SELECT "customer_unique_id",
           COUNT("order_id") AS "total_orders",
           NTILE(5) OVER (ORDER BY COUNT("order_id") DESC) AS "frequency"
    FROM E_COMMERCE.E_COMMERCE.ORDERS
        JOIN E_COMMERCE.E_COMMERCE.CUSTOMERS USING ("customer_id")
    WHERE "order_status" = 'delivered'
    GROUP BY "customer_unique_id"
),
MonetaryScore AS (
    SELECT "customer_unique_id",
           SUM("price") AS "total_spent",
           NTILE(5) OVER (ORDER BY SUM("price") DESC) AS "monetary"
    FROM E_COMMERCE.E_COMMERCE.ORDERS
        JOIN E_COMMERCE.E_COMMERCE.ORDER_ITEMS USING ("order_id")
        JOIN E_COMMERCE.E_COMMERCE.CUSTOMERS USING ("customer_id")
    WHERE "order_status" = 'delivered'
    GROUP BY "customer_unique_id"
),

RFM AS (
    SELECT "last_purchase", "total_orders", "total_spent",
        CASE
            WHEN "recency" = 1 AND "frequency" + "monetary" IN (1, 2, 3, 4) THEN 'Champions'
            WHEN "recency" IN (4, 5) AND "frequency" + "monetary" IN (1, 2) THEN 'Can\'t Lose Them'
            WHEN "recency" IN (4, 5) AND "frequency" + "monetary" IN (3, 4, 5, 6) THEN 'Hibernating'
            WHEN "recency" IN (4, 5) AND "frequency" + "monetary" IN (7, 8, 9, 10) THEN 'Lost'
            WHEN "recency" IN (2, 3) AND "frequency" + "monetary" IN (1, 2, 3, 4) THEN 'Loyal Customers'
            WHEN "recency" = 3 AND "frequency" + "monetary" IN (5, 6) THEN 'Needs Attention'
            WHEN "recency" = 1 AND "frequency" + "monetary" IN (7, 8) THEN 'Recent Users'
            WHEN "recency" = 1 AND "frequency" + "monetary" IN (5, 6) OR
                 "recency" = 2 AND "frequency" + "monetary" IN (5, 6, 7, 8) THEN 'Potentital Loyalists'
            WHEN "recency" = 1 AND "frequency" + "monetary" IN (9, 10) THEN 'Price Sensitive'
            WHEN "recency" = 2 AND "frequency" + "monetary" IN (9, 10) THEN 'Promising'
            WHEN "recency" = 3 AND "frequency" + "monetary" IN (7, 8, 9, 10) THEN 'About to Sleep'
        END AS "RFM_Bucket"
    FROM RecencyScore
        JOIN FrequencyScore USING ("customer_unique_id")
        JOIN MonetaryScore USING ("customer_unique_id")
)

SELECT "RFM_Bucket", 
       AVG("total_spent" / "total_orders") AS "avg_sales_per_customer"
FROM RFM
GROUP BY "RFM_Bucket"