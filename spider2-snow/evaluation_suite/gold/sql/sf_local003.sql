WITH CustomerOrderStats AS (
    SELECT
        C."customer_unique_id",
        O."order_id",
        TO_TIMESTAMP(O."order_purchase_timestamp") AS "order_purchase_timestamp",
        P."payment_value"
    FROM "E_COMMERCE"."E_COMMERCE"."CUSTOMERS" AS C
    JOIN "E_COMMERCE"."E_COMMERCE"."ORDERS" AS O
        ON C."customer_id" = O."customer_id"
    JOIN "E_COMMERCE"."E_COMMERCE"."ORDER_PAYMENTS" AS P
        ON O."order_id" = P."order_id"
    WHERE O."order_status" = 'delivered'
),
MaxDate AS (
    SELECT MAX("order_purchase_timestamp") AS "max_purchase_date" FROM CustomerOrderStats
),
RFM_Base AS (
    SELECT
        "customer_unique_id",
        DATEDIFF(day, MAX("order_purchase_timestamp"), (SELECT "max_purchase_date" FROM MaxDate)) AS "Recency",
        COUNT(DISTINCT "order_id") AS "Frequency",
        SUM("payment_value") AS "Monetary",
        COUNT(DISTINCT "order_id") AS "TotalOrders",
        SUM("payment_value") AS "TotalSpend"
    FROM CustomerOrderStats
    GROUP BY "customer_unique_id"
),
RFM_Scores AS (
    SELECT
        *,
        NTILE(5) OVER (ORDER BY "Recency" ASC) AS "R",
        NTILE(5) OVER (ORDER BY "Frequency" DESC) AS "F",
        NTILE(5) OVER (ORDER BY "Monetary" DESC) AS "M"
    FROM RFM_Base
),
RFM_Segments AS (
    SELECT
        *,
        CASE
            WHEN "R" = 1 AND ("F" + "M") BETWEEN 1 AND 4 THEN 'Champions'
            WHEN ("R" = 4 OR "R" = 5) AND ("F" + "M") BETWEEN 1 AND 2 THEN 'Can''t Lose Them'
            WHEN ("R" = 4 OR "R" = 5) AND ("F" + "M") BETWEEN 3 AND 6 THEN 'Hibernating'
            WHEN ("R" = 4 OR "R" = 5) AND ("F" + "M") BETWEEN 7 AND 10 THEN 'Lost'
            WHEN ("R" = 2 OR "R" = 3) AND ("F" + "M") BETWEEN 1 AND 4 THEN 'Loyal Customers'
            WHEN "R" = 3 AND ("F" + "M") BETWEEN 5 AND 6 THEN 'Needs Attention'
            WHEN "R" = 1 AND ("F" + "M") BETWEEN 7 AND 8 THEN 'Recent Users'
            WHEN ("R" = 1 AND ("F" + "M") BETWEEN 5 AND 6) OR ("R" = 2 AND ("F" + "M") BETWEEN 5 AND 8) THEN 'Potential Loyalists'
            WHEN "R" = 1 AND ("F" + "M") BETWEEN 9 AND 10 THEN 'Price Sensitive'
            WHEN "R" = 2 AND ("F" + "M") BETWEEN 9 AND 10 THEN 'Promising'
            WHEN "R" = 3 AND ("F" + "M") BETWEEN 7 AND 10 THEN 'About to Sleep'
            ELSE 'Others'
        END AS "RFM_Segment"
    FROM RFM_Scores
)
SELECT
    "RFM_Segment",
    SUM("TotalSpend") / SUM("TotalOrders") AS "AverageSalesPerOrder"
FROM RFM_Segments
GROUP BY "RFM_Segment"
ORDER BY "AverageSalesPerOrder" DESC