WITH users_2019 AS (
  SELECT "id" AS "user_id", "email"
  FROM THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.USERS
  WHERE TO_TIMESTAMP_NTZ("created_at" / 1000000.0) >= TO_TIMESTAMP_NTZ('2019-01-01')
    AND TO_TIMESTAMP_NTZ("created_at" / 1000000.0) < TO_TIMESTAMP_NTZ('2020-01-01')
),
orders_2019 AS (
  SELECT "order_id", "user_id"
  FROM THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.ORDERS
  WHERE TO_TIMESTAMP_NTZ("created_at" / 1000000.0) >= TO_TIMESTAMP_NTZ('2019-01-01')
    AND TO_TIMESTAMP_NTZ("created_at" / 1000000.0) < TO_TIMESTAMP_NTZ('2020-01-01')
    AND "status" NOT IN ('Cancelled','Returned')
),
order_items_valid AS (
  SELECT "order_id", "sale_price"
  FROM THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.ORDER_ITEMS
  WHERE "status" NOT IN ('Cancelled','Returned')
    AND "sale_price" IS NOT NULL
),
per_order_revenue AS (
  SELECT o."order_id", o."user_id",
         SUM(oi."sale_price") AS "order_revenue"
  FROM orders_2019 o
  JOIN order_items_valid oi
    ON o."order_id" = oi."order_id"
  GROUP BY o."order_id", o."user_id"
),
per_user AS (
  SELECT por."user_id",
         SUM(por."order_revenue") AS "total_revenue",
         COUNT(DISTINCT por."order_id") AS "order_count",
         SUM(por."order_revenue") / NULLIF(COUNT(DISTINCT por."order_id"), 0) AS "aov"
  FROM per_order_revenue por
  GROUP BY por."user_id"
)
SELECT u."email" AS "email"
FROM users_2019 u
JOIN per_user p
  ON u."user_id" = p."user_id"
ORDER BY p."aov" DESC NULLS LAST, u."email" ASC
LIMIT 10;