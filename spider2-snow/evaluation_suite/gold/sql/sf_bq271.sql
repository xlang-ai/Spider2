SELECT
  TO_CHAR(DATE_TRUNC('month', TO_TIMESTAMP_LTZ("ORDERS"."created_at" / 1000000)), 'YYYY-MM') AS "order_month",
  "USERS"."country" AS "country",
  "INVENTORY_ITEMS"."product_department" AS "product_department",
  "INVENTORY_ITEMS"."product_category" AS "product_category",
  COUNT(DISTINCT "ORDERS"."order_id") AS "num_orders",
  COUNT(DISTINCT "ORDERS"."user_id") AS "unique_purchasers",
  SUM(COALESCE("INVENTORY_ITEMS"."product_retail_price",0)) - SUM(COALESCE("INVENTORY_ITEMS"."cost",0)) AS "profit"
FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."ORDERS" "ORDERS"
JOIN "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."USERS" "USERS"
  ON "ORDERS"."user_id" = "USERS"."id"
JOIN "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."ORDER_ITEMS" "ORDER_ITEMS"
  ON "ORDERS"."order_id" = "ORDER_ITEMS"."order_id"
JOIN "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."INVENTORY_ITEMS" "INVENTORY_ITEMS"
  ON "ORDER_ITEMS"."inventory_item_id" = "INVENTORY_ITEMS"."id"
WHERE
  "ORDERS"."created_at" >= 1609459200000000
  AND "ORDERS"."created_at" < 1640995200000000
  AND "USERS"."created_at" >= 1609459200000000
  AND "USERS"."created_at" < 1640995200000000
  AND "INVENTORY_ITEMS"."created_at" >= 1609459200000000
  AND "INVENTORY_ITEMS"."created_at" < 1640995200000000
GROUP BY
  DATE_TRUNC('month', TO_TIMESTAMP_LTZ("ORDERS"."created_at" / 1000000)),
  "USERS"."country",
  "INVENTORY_ITEMS"."product_department",
  "INVENTORY_ITEMS"."product_category"
ORDER BY
  "order_month",
  "country",
  "product_department",
  "product_category";