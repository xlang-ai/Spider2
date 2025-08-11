WITH double_entry_book AS (
    -- Debits
    SELECT 
        "to_address" AS "address", 
        "value" AS "value"
    FROM 
        CRYPTO.CRYPTO_ETHEREUM_CLASSIC.TRACES
    WHERE 
        "to_address" IS NOT NULL
        AND "status" = 1
        AND ("call_type" NOT IN ('delegatecall', 'callcode', 'staticcall') OR "call_type" IS NULL)
        AND TO_DATE(TO_TIMESTAMP("block_timestamp" / 1000000)) = '2016-10-14'

    UNION ALL
    
    -- Credits
    SELECT 
        "from_address" AS "address", 
        - "value" AS "value"
    FROM 
        CRYPTO.CRYPTO_ETHEREUM_CLASSIC.TRACES
    WHERE 
        "from_address" IS NOT NULL
        AND "status" = 1
        AND ("call_type" NOT IN ('delegatecall', 'callcode', 'staticcall') OR "call_type" IS NULL)
        AND TO_DATE(TO_TIMESTAMP("block_timestamp" / 1000000)) = '2016-10-14'

    UNION ALL

    -- Transaction Fees Debits
    SELECT 
        "miner" AS "address", 
        SUM(CAST("receipt_gas_used" AS NUMERIC) * CAST("gas_price" AS NUMERIC)) AS "value"
    FROM 
        CRYPTO.CRYPTO_ETHEREUM_CLASSIC.TRANSACTIONS AS "transactions"
    JOIN 
        CRYPTO.CRYPTO_ETHEREUM_CLASSIC.BLOCKS AS "blocks" 
        ON "blocks"."number" = "transactions"."block_number"
    WHERE 
        TO_DATE(TO_TIMESTAMP("block_timestamp" / 1000000)) = '2016-10-14'
    GROUP BY 
        "blocks"."miner"

    UNION ALL
    
    -- Transaction Fees Credits
    SELECT 
        "from_address" AS "address", 
        -(CAST("receipt_gas_used" AS NUMERIC) * CAST("gas_price" AS NUMERIC)) AS "value"
    FROM 
        CRYPTO.CRYPTO_ETHEREUM_CLASSIC.TRANSACTIONS
    WHERE 
        TO_DATE(TO_TIMESTAMP("block_timestamp" / 1000000)) = '2016-10-14'
),
net_changes AS (
    SELECT 
        "address",
        SUM("value") AS "net_change"
    FROM 
        double_entry_book
    GROUP BY 
        "address"
)
SELECT 
    MAX("net_change") AS "max_net_change",
    MIN("net_change") AS "min_net_change"
FROM
    net_changes;