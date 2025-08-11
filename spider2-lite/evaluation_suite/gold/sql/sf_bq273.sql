WITH 
orders AS (
  SELECT
    "order_id", 
    "user_id", 
    "created_at",
    DATE_TRUNC('MONTH', TO_TIMESTAMP_NTZ("delivered_at" / 1000000)) AS "delivery_month",  -- Converting to timestamp
    "status" 
  FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."ORDERS"
),

order_items AS (
  SELECT 
    "order_id", 
    "product_id", 
    "sale_price" 
  FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."ORDER_ITEMS"
),

products AS (
  SELECT 
    "id", 
    "cost"
  FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."PRODUCTS"
),

users AS (
  SELECT
    "id", 
    "traffic_source" 
  FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."USERS"
),

filter_join AS (
  SELECT 
    orders."order_id",
    orders."user_id",
    order_items."product_id",
    orders."delivery_month",
    orders."status",
    order_items."sale_price",
    products."cost",
    users."traffic_source"
  FROM orders
  JOIN order_items ON orders."order_id" = order_items."order_id"
  JOIN products ON order_items."product_id" = products."id"
  JOIN users ON orders."user_id" = users."id"
  WHERE orders."status" = 'Complete' 
    AND users."traffic_source" = 'Facebook'
    AND TO_TIMESTAMP_NTZ(orders."created_at" / 1000000) BETWEEN TO_TIMESTAMP_NTZ('2022-07-01') AND TO_TIMESTAMP_NTZ('2023-11-30')  -- Include July for calculation
),

monthly_sales AS (
  SELECT 
    "delivery_month",
    "traffic_source",
    SUM("sale_price") AS "total_revenue",
    SUM("sale_price") - SUM("cost") AS "total_profit",
    COUNT(DISTINCT "product_id") AS "product_quantity",
    COUNT(DISTINCT "order_id") AS "orders_quantity",
    COUNT(DISTINCT "user_id") AS "users_quantity"
  FROM filter_join
  GROUP BY "delivery_month", "traffic_source"
)

-- Filter to show only 8th month and onwards, but calculate using July
SELECT 
  current_month."delivery_month",
  COALESCE(
    current_month."total_profit" - previous_month."total_profit", 
    0  -- If there is no previous month (i.e. for 8月), return 0
  ) AS "profit_vs_prior_month"
FROM monthly_sales AS current_month
LEFT JOIN monthly_sales AS previous_month
  ON current_month."traffic_source" = previous_month."traffic_source"
  AND current_month."delivery_month" = DATEADD(MONTH, -1, previous_month."delivery_month")  -- Correctly join to previous month
WHERE current_month."delivery_month" >= '2022-08-01'  -- Only show August and later data, but use July for calculation
ORDER BY "profit_vs_prior_month" DESC
LIMIT 5;
