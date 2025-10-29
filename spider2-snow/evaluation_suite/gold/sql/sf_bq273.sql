WITH "order_profit" AS (
    SELECT
        CAST(DATE_TRUNC('month', TO_TIMESTAMP("o"."delivered_at" / 1000000)) AS DATE) AS "delivery_month",
        "o"."order_id",
        SUM("oi"."sale_price" - COALESCE("ii"."cost", 0)) AS "order_profit"
    FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."ORDERS" AS "o"
    JOIN "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."USERS" AS "u"
        ON "o"."user_id" = "u"."id"
    JOIN "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."ORDER_ITEMS" AS "oi"
        ON "o"."order_id" = "oi"."order_id"
    LEFT JOIN "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."INVENTORY_ITEMS" AS "ii"
        ON "oi"."inventory_item_id" = "ii"."id"
    WHERE "o"."status" = 'Complete'
      AND "u"."traffic_source" = 'Facebook'
      AND TO_TIMESTAMP("o"."created_at" / 1000000) >= TO_TIMESTAMP('2022-08-01')
      AND TO_TIMESTAMP("o"."created_at" / 1000000) < TO_TIMESTAMP('2023-12-01')
      AND "o"."delivered_at" IS NOT NULL
    GROUP BY 1, 2
),
"monthly_profit" AS (
    SELECT
        "delivery_month",
        SUM("order_profit") AS "monthly_profit"
    FROM "order_profit"
    WHERE "delivery_month" >= DATE '2022-08-01'
      AND "delivery_month" <= DATE '2023-11-01'
    GROUP BY 1
),
"monthly_changes" AS (
    SELECT
        "delivery_month",
        "monthly_profit",
        "monthly_profit" - LAG("monthly_profit") OVER (ORDER BY "delivery_month") AS "profit_increase"
    FROM "monthly_profit"
)
SELECT
    "delivery_month",
    "monthly_profit",
    "profit_increase"
FROM "monthly_changes"
WHERE "profit_increase" IS NOT NULL
ORDER BY "profit_increase" DESC, "delivery_month"
LIMIT 5