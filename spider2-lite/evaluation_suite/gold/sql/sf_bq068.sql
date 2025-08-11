WITH double_entry_book AS (
    -- debits
    SELECT
        ARRAY_TO_STRING("inputs".value:addresses, ',') AS "address",  -- Use the correct JSON path notation
        "inputs".value:type AS "type",
        - "inputs".value:value AS "value"
    FROM CRYPTO.CRYPTO_BITCOIN_CASH.TRANSACTIONS,
         LATERAL FLATTEN(INPUT => "inputs") AS "inputs"
    WHERE TO_TIMESTAMP("block_timestamp" / 1000000) >= '2014-03-01' 
      AND TO_TIMESTAMP("block_timestamp" / 1000000) < '2014-04-01'

    UNION ALL
 
    -- credits
    SELECT
        ARRAY_TO_STRING("outputs".value:addresses, ',') AS "address",  -- Use the correct JSON path notation
        "outputs".value:type AS "type",
        "outputs".value:value AS "value"
    FROM CRYPTO.CRYPTO_BITCOIN_CASH.TRANSACTIONS, 
         LATERAL FLATTEN(INPUT => "outputs") AS "outputs"
    WHERE TO_TIMESTAMP("block_timestamp" / 1000000) >= '2014-03-01' 
      AND TO_TIMESTAMP("block_timestamp" / 1000000) < '2014-04-01'
),
address_balances AS (
    SELECT 
        "address",
        "type",
        SUM("value") AS "balance"
    FROM double_entry_book
    GROUP BY "address", "type"
),
max_min_balances AS (
    SELECT
        "type",
        MAX("balance") AS max_balance,
        MIN("balance") AS min_balance
    FROM address_balances
    GROUP BY "type"
)
SELECT
    REPLACE("type", '"', '') AS "type",  -- Replace double quotes with nothing
    max_balance,
    min_balance
FROM max_min_balances
ORDER BY "type";
