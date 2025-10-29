WITH date_range AS (
    SELECT 
        DATE_PART(EPOCH_MICROSECOND, '2014-03-01'::TIMESTAMP) AS start_timestamp,
        DATE_PART(EPOCH_MICROSECOND, '2014-04-01'::TIMESTAMP) AS end_timestamp
),
address_transactions AS (
    -- Get all debits (inputs) within the date range
    SELECT 
        FLATTENED.value::STRING AS address,
        i."type" AS address_type,
        -i."value" AS amount,
        i."block_timestamp"
    FROM "CRYPTO"."CRYPTO_BITCOIN_CASH"."INPUTS" i,
    LATERAL FLATTEN(input => PARSE_JSON(i."addresses")) FLATTENED
    WHERE i."block_timestamp" BETWEEN (SELECT start_timestamp FROM date_range) AND (SELECT end_timestamp FROM date_range)
    
    UNION ALL
    
    -- Get all credits (outputs) within the date range
    SELECT 
        FLATTENED.value::STRING AS address,
        o."type" AS address_type,
        o."value" AS amount,
        o."block_timestamp"
    FROM "CRYPTO"."CRYPTO_BITCOIN_CASH"."OUTPUTS" o,
    LATERAL FLATTEN(input => PARSE_JSON(o."addresses")) FLATTENED
    WHERE o."block_timestamp" BETWEEN (SELECT start_timestamp FROM date_range) AND (SELECT end_timestamp FROM date_range)
),
address_balances AS (
    SELECT 
        address,
        address_type,
        SUM(amount) AS final_balance
    FROM address_transactions
    GROUP BY address, address_type
)
SELECT 
    address_type,
    MAX(final_balance) AS max_final_balance,
    MIN(final_balance) AS min_final_balance
FROM address_balances
GROUP BY address_type
ORDER BY address_type;