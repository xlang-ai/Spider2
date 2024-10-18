WITH double_entry_book AS (
    -- Debits
    SELECT 
        to_address AS address, 
        value AS value
    FROM 
        `bigquery-public-data.crypto_ethereum_classic.traces`
    WHERE 
        to_address IS NOT NULL
        AND status = 1
        AND (call_type NOT IN ('delegatecall', 'callcode', 'staticcall') OR call_type IS NULL)
        AND EXTRACT(DATE FROM block_timestamp) = '2016-10-14'

    UNION ALL
    
    -- Credits
    SELECT 
        from_address AS address, 
        -value AS value
    FROM 
        `bigquery-public-data.crypto_ethereum_classic.traces`
    WHERE 
        from_address IS NOT NULL
        AND status = 1
        AND (call_type NOT IN ('delegatecall', 'callcode', 'staticcall') OR call_type IS NULL)
        AND EXTRACT(DATE FROM block_timestamp) = '2016-10-14'

    UNION ALL

    -- Transaction Fees Debits
    SELECT 
        miner AS address, 
        SUM(CAST(receipt_gas_used AS NUMERIC) * CAST(gas_price AS NUMERIC)) AS value
    FROM 
        `bigquery-public-data.crypto_ethereum_classic.transactions` AS transactions
    JOIN 
        `bigquery-public-data.crypto_ethereum_classic.blocks` AS blocks 
        ON blocks.number = transactions.block_number
    WHERE 
        EXTRACT(DATE FROM block_timestamp) = '2016-10-14'
    GROUP BY 
        blocks.miner, 
        block_timestamp

    UNION ALL
    
    -- Transaction Fees Credits
    SELECT 
        from_address AS address, 
        -(CAST(receipt_gas_used AS NUMERIC) * CAST(gas_price AS NUMERIC)) AS value
    FROM 
        `bigquery-public-data.crypto_ethereum_classic.transactions`
    WHERE 
        EXTRACT(DATE FROM block_timestamp) = '2016-10-14'
),
net_changes AS (
    SELECT 
        address,
        SUM(value) AS net_change
    FROM 
        double_entry_book
    GROUP BY 
        address
)
select 
    MAX(net_change) AS max_net_change,
    MIN(net_change) AS min_net_change
FROM
    net_changes;