SELECT
  DATE_TRUNC('month', TO_TIMESTAMP_NTZ("O"."created_at" / 1000000)) AS "month",
  SUM("OI"."sale_price") AS "total_sales",
  SUM("P"."cost") AS "total_cost",
  COUNT(DISTINCT "O"."order_id") AS "complete_orders",
  SUM("OI"."sale_price" - "P"."cost") AS "total_profit",
  CASE WHEN SUM("P"."cost") = 0 THEN NULL ELSE SUM("OI"."sale_price" - "P"."cost") / SUM("P"."cost") END AS "profit_to_cost_ratio"
FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."ORDER_ITEMS" AS "OI"
JOIN "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."ORDERS" AS "O"
  ON "OI"."order_id" = "O"."order_id"
JOIN "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."PRODUCTS" AS "P"
  ON "OI"."product_id" = "P"."id"
WHERE "O"."status" = 'Complete'
  AND "P"."category" = 'Sleep & Lounge'
  AND TO_TIMESTAMP_NTZ("O"."created_at" / 1000000) >= '2023-01-01'
  AND TO_TIMESTAMP_NTZ("O"."created_at" / 1000000) < '2024-01-01'
GROUP BY 1
ORDER BY 1;