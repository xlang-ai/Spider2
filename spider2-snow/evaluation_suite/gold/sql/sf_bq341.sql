WITH transaction_addresses AS (
    SELECT 
        "from_address", 
        "to_address", 
        CAST("value" AS NUMERIC) / 1000000 AS "value"
    FROM 
        "CRYPTO"."CRYPTO_ETHEREUM"."TOKEN_TRANSFERS"
    WHERE 
        "token_address" = '0xa92a861fc11b99b24296af880011b47f9cafb5ab'
),

out_addresses AS (
    SELECT 
        "from_address", 
        SUM(-1 * "value") AS "total_value"
    FROM 
        transaction_addresses
    GROUP BY 
        "from_address"
),

in_addresses AS (
    SELECT 
        "to_address", 
        SUM("value") AS "total_value"
    FROM 
        transaction_addresses
    GROUP BY 
        "to_address"
),

all_addresses AS (
    SELECT 
        "from_address" AS "address", 
        "total_value"
    FROM 
        out_addresses

    UNION ALL

    SELECT 
        "to_address" AS "address", 
        "total_value"
    FROM 
        in_addresses
)

SELECT 
    "address"
FROM 
    all_addresses
GROUP BY 
    "address"
HAVING 
    SUM("total_value") > 0
ORDER BY 
    SUM("total_value") ASC
LIMIT 3;
