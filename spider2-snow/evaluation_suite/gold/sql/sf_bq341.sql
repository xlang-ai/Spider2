WITH address_balances AS (
    SELECT 
        address,
        SUM(CASE WHEN direction = 'in' THEN value_numeric ELSE -value_numeric END) AS balance
    FROM (
        SELECT 
            "to_address" AS address,
            CAST("value" AS NUMBER(38,0)) AS value_numeric,
            'in' AS direction
        FROM CRYPTO.CRYPTO_ETHEREUM.TOKEN_TRANSFERS 
        WHERE "token_address" = '0xa92a861fc11b99b24296af880011b47f9cafb5ab'
        
        UNION ALL
        
        SELECT 
            "from_address" AS address,
            CAST("value" AS NUMBER(38,0)) AS value_numeric,
            'out' AS direction
        FROM CRYPTO.CRYPTO_ETHEREUM.TOKEN_TRANSFERS 
        WHERE "token_address" = '0xa92a861fc11b99b24296af880011b47f9cafb5ab'
    )
    WHERE address != '0x0000000000000000000000000000000000000000'
    GROUP BY address
)
SELECT address
FROM address_balances
WHERE balance > 0
ORDER BY balance ASC
LIMIT 3