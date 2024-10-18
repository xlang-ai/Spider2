WITH all_transactions AS (
    -- Combine inputs and outputs
    SELECT 
        ARRAY_TO_STRING(addresses, ",") AS address,
        value,
        block_timestamp AS timestamp
    FROM `spider2-public-data.crypto_bitcoin.inputs`
    
    UNION ALL
    
    SELECT 
        ARRAY_TO_STRING(addresses, ",") AS address,
        value,
        block_timestamp AS timestamp
    FROM `spider2-public-data.crypto_bitcoin.outputs`
),

filtered_transactions AS (
    -- Filter for transactions in October 2017
    SELECT
        address,
        value,
        timestamp
    FROM all_transactions
    WHERE EXTRACT(YEAR FROM timestamp) = 2017
      AND EXTRACT(MONTH FROM timestamp) = 10
),

aggregated_data AS (
    -- Aggregate transaction data by address
    SELECT
        address,
        SUM(value) AS total_value,
        MAX(timestamp) AS last_transaction
    FROM filtered_transactions
    GROUP BY address
),

--Find the address with the highest total value and latest transaction in October 2017
final_result AS (
    SELECT
        address
    FROM aggregated_data
    WHERE last_transaction = (
        SELECT MAX(last_transaction)
        FROM aggregated_data
    )
    ORDER BY total_value DESC
    LIMIT 1
)

-- Return the result
SELECT address
FROM final_result;