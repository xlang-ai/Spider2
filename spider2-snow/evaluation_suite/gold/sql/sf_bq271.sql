WITH
orders_x_order_items AS (
  SELECT orders.*,
         order_items."inventory_item_id",
         order_items."sale_price"
  FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."ORDERS" AS orders
  LEFT JOIN "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."ORDER_ITEMS" AS order_items
  ON orders."order_id" = order_items."order_id"
  WHERE TO_TIMESTAMP_NTZ(orders."created_at" / 1000000) BETWEEN TO_TIMESTAMP_NTZ('2021-01-01') AND TO_TIMESTAMP_NTZ('2021-12-31')
),

orders_x_inventory AS (
  SELECT orders_x_order_items.*,
         inventory_items."product_category",
         inventory_items."product_department",
         inventory_items."product_retail_price",
         inventory_items."product_distribution_center_id",
         inventory_items."cost",
         distribution_centers."name"
  FROM orders_x_order_items
  LEFT JOIN "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."INVENTORY_ITEMS" AS inventory_items
  ON orders_x_order_items."inventory_item_id" = inventory_items."id"
  LEFT JOIN "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."DISTRIBUTION_CENTERS" AS distribution_centers
  ON inventory_items."product_distribution_center_id" = distribution_centers."id"
  WHERE TO_TIMESTAMP_NTZ(inventory_items."created_at" / 1000000) BETWEEN TO_TIMESTAMP_NTZ('2021-01-01') AND TO_TIMESTAMP_NTZ('2021-12-31')
),

orders_x_users AS (
  SELECT orders_x_inventory.*,
         users."country" AS "users_country"
  FROM orders_x_inventory
  LEFT JOIN "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."USERS" AS users
  ON orders_x_inventory."user_id" = users."id"
  WHERE TO_TIMESTAMP_NTZ(users."created_at" / 1000000) BETWEEN TO_TIMESTAMP_NTZ('2021-01-01') AND TO_TIMESTAMP_NTZ('2021-12-31')
)

SELECT 
  DATE_TRUNC('MONTH', TO_DATE(TO_TIMESTAMP_NTZ(orders_x_users."created_at" / 1000000))) AS "reporting_month",
  orders_x_users."users_country",
  orders_x_users."product_department",
  orders_x_users."product_category",
  COUNT(DISTINCT orders_x_users."order_id") AS "n_order",
  COUNT(DISTINCT orders_x_users."user_id") AS "n_purchasers",
  SUM(orders_x_users."product_retail_price") - SUM(orders_x_users."cost") AS "profit"
FROM orders_x_users
GROUP BY 1, 2, 3, 4
ORDER BY "reporting_month";
