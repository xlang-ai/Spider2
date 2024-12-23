WITH youngest AS (
    SELECT
        "gender", 
        "id", 
        "first_name", 
        "last_name", 
        "age", 
        'youngest' AS "tag"
    FROM 
        "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."USERS"
    WHERE 
        "age" = (SELECT MIN("age") FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."USERS")
        AND TO_TIMESTAMP("created_at" / 1000000.0) BETWEEN TO_TIMESTAMP('2019-01-01') AND TO_TIMESTAMP('2022-04-30')
    GROUP BY 
        "gender", "id", "first_name", "last_name", "age"
    ORDER BY 
        "gender"
),

oldest AS (
    SELECT
        "gender", 
        "id", 
        "first_name", 
        "last_name", 
        "age", 
        'oldest' AS "tag"
    FROM 
        "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."USERS"
    WHERE 
        "age" = (SELECT MAX("age") FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."USERS")
        AND TO_TIMESTAMP("created_at" / 1000000.0) BETWEEN TO_TIMESTAMP('2019-01-01') AND TO_TIMESTAMP('2022-04-30')
    GROUP BY 
        "gender", "id", "first_name", "last_name", "age"
    ORDER BY 
        "gender"
),

TEMP_record AS (
    SELECT * FROM youngest
    UNION ALL
    SELECT * FROM oldest
)

SELECT 
    SUM(CASE WHEN "age" = (SELECT MAX("age") FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."USERS") THEN 1 END) - 
    SUM(CASE WHEN "age" = (SELECT MIN("age") FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."USERS") THEN 1 END) AS "diff"
FROM 
    TEMP_record;
