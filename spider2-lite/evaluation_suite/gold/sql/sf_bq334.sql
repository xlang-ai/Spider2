WITH all_transactions AS (
    SELECT 
        TO_TIMESTAMP_NTZ("block_timestamp" / 1000000) AS "timestamp",  -- 将时间戳转换为日期时间格式
        "value",
        'input' AS "type"
    FROM 
        "CRYPTO"."CRYPTO_BITCOIN"."INPUTS"
    UNION ALL
    SELECT 
        TO_TIMESTAMP_NTZ("block_timestamp" / 1000000) AS "timestamp",  -- 将时间戳转换为日期时间格式
        "value",
        'output' AS "type"
    FROM 
        "CRYPTO"."CRYPTO_BITCOIN"."OUTPUTS"
),
filtered_transactions AS (
    SELECT
        EXTRACT(YEAR FROM "timestamp") AS "year",
        "value"
    FROM 
        all_transactions
    WHERE "type" = 'output'
),
average_output_values AS (
    SELECT
        "year",
        AVG("value") AS "avg_value"
    FROM 
        filtered_transactions
    GROUP BY "year"
),
average_transaction_values AS (
    SELECT 
        EXTRACT(YEAR FROM TO_TIMESTAMP_NTZ("block_timestamp" / 1000000)) AS "year",  -- 同样转换时间戳
        AVG("output_value") AS "avg_transaction_value" 
    FROM 
        "CRYPTO"."CRYPTO_BITCOIN"."TRANSACTIONS" 
    GROUP BY "year" 
    ORDER BY "year"
),
common_years AS (
    SELECT
        ao."year",
        ao."avg_value" AS "avg_output_value",
        atv."avg_transaction_value"
    FROM
        average_output_values ao
    JOIN
        average_transaction_values atv 
        ON ao."year" = atv."year"
)

SELECT
    "year",
    "avg_transaction_value" - "avg_output_value" AS "difference"
FROM
    common_years
ORDER BY
    "year";
