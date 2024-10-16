WITH all_transactions AS (
    -- Combine inputs and outputs
    SELECT 
        block_timestamp AS timestamp,
        value,
        'input' AS type
    FROM 
        `spider2-public-data.crypto_bitcoin.inputs`
    
    UNION ALL
    
    SELECT 
        block_timestamp AS timestamp,
        value,
        'output' AS type
    FROM 
        `spider2-public-data.crypto_bitcoin.outputs`
),
filtered_transactions AS (
    -- Filter for output transactions and extract the year
    SELECT
        EXTRACT(YEAR FROM timestamp) AS year,
        value
    FROM 
        all_transactions
    WHERE type = 'output'
),
average_values AS (
    -- Calculate average value per year
    SELECT
        year,
        AVG(value) AS avg_value
    FROM 
        filtered_transactions
    GROUP BY year
)
-- Select the year with the highest average value
SELECT
    year
FROM 
    average_values
ORDER BY avg_value DESC
LIMIT 1;