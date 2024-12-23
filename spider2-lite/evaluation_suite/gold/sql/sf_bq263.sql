WITH d AS (
    SELECT
        a."order_id", 
        TO_CHAR(TO_TIMESTAMP(a."created_at" / 1000000.0), 'YYYY-MM') AS "month",  -- 格式化为年月
        TO_CHAR(TO_TIMESTAMP(a."created_at" / 1000000.0), 'YYYY') AS "year",  -- 格式化为年份
        b."product_id", b."sale_price", c."category", c."cost"
    FROM 
        "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."ORDERS" AS a
    JOIN 
        "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."ORDER_ITEMS" AS b
        ON a."order_id" = b."order_id"
    JOIN 
        "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."PRODUCTS" AS c
        ON b."product_id" = c."id"
    WHERE 
        a."status" = 'Complete'
        AND TO_TIMESTAMP(a."created_at" / 1000000.0) BETWEEN TO_TIMESTAMP('2023-01-01') AND TO_TIMESTAMP('2023-12-31')
        AND c."category" = 'Sleep & Lounge'
),

e AS (
    SELECT 
        "month", 
        "year", 
        "sale_price", 
        "category", 
        "cost",
        SUM("sale_price") OVER (PARTITION BY "month", "category") AS "TPV",
        SUM("cost") OVER (PARTITION BY "month", "category") AS "total_cost",
        COUNT(DISTINCT "order_id") OVER (PARTITION BY "month", "category") AS "TPO",
        SUM("sale_price" - "cost") OVER (PARTITION BY "month", "category") AS "total_profit",
        SUM(("sale_price" - "cost") / "cost") OVER (PARTITION BY "month", "category") AS "Profit_to_cost_ratio"
    FROM 
        d
)

SELECT DISTINCT 
    "month", 
    "category", 
    "TPV", 
    "total_cost", 
    "TPO", 
    "total_profit", 
    "Profit_to_cost_ratio"
FROM 
    e
ORDER BY 
    "month";
