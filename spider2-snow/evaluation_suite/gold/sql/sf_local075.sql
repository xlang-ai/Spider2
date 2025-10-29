WITH "product_events" AS (
  SELECT
    p."product_id",
    p."page_name",
    p."product_category",
    e."visit_id",
    e."event_type",
    e."sequence_number"
  FROM "BANK_SALES_TRADING"."BANK_SALES_TRADING"."SHOPPING_CART_EVENTS" e
  JOIN "BANK_SALES_TRADING"."BANK_SALES_TRADING"."SHOPPING_CART_PAGE_HIERARCHY" p
    ON e."page_id" = p."page_id"
  WHERE p."product_id" IS NOT NULL
    AND p."page_id" NOT IN (1, 2, 12, 13)
),
"views_agg" AS (
  SELECT
    "product_id",
    "page_name",
    "product_category",
    COUNT(*) AS "total_views"
  FROM "product_events"
  WHERE "event_type" = 1
  GROUP BY "product_id", "page_name", "product_category"
),
"adds" AS (
  SELECT
    "product_id",
    "page_name",
    "product_category",
    "visit_id",
    "sequence_number" AS "add_seq"
  FROM "product_events"
  WHERE "event_type" = 2
),
"purchases" AS (
  SELECT
    "visit_id",
    "sequence_number" AS "purchase_seq"
  FROM "BANK_SALES_TRADING"."BANK_SALES_TRADING"."SHOPPING_CART_EVENTS"
  WHERE "event_type" = 3
),
"add_outcomes" AS (
  SELECT
    a."product_id",
    a."page_name",
    a."product_category",
    a."visit_id",
    a."add_seq",
    CASE WHEN EXISTS (
      SELECT 1 FROM "purchases" p
      WHERE p."visit_id" = a."visit_id"
        AND p."purchase_seq" > a."add_seq"
    ) THEN 1 ELSE 0 END AS "purchased_flag"
  FROM "adds" a
),
"add_agg" AS (
  SELECT
    "product_id",
    "page_name",
    "product_category",
    COUNT(*) AS "total_adds_to_cart",
    SUM("purchased_flag") AS "total_purchases",
    COUNT(*) - SUM("purchased_flag") AS "left_in_cart_without_purchase"
  FROM "add_outcomes"
  GROUP BY "product_id", "page_name", "product_category"
)
SELECT
  v."product_id",
  v."page_name",
  v."product_category",
  v."total_views",
  COALESCE(a."total_adds_to_cart", 0) AS "total_adds_to_cart",
  COALESCE(a."left_in_cart_without_purchase", 0) AS "left_in_cart_without_purchase",
  COALESCE(a."total_purchases", 0) AS "total_purchases"
FROM "views_agg" v
LEFT JOIN "add_agg" a
  ON v."product_id" = a."product_id"
 AND v."page_name" = a."page_name"
 AND v."product_category" = a."product_category"
ORDER BY v."product_id";