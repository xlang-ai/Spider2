WITH value_table AS (
    SELECT to_address AS address, value AS value
    FROM `spider2-public-data.crypto_ethereum.traces`
    WHERE to_address IS NOT null
    AND block_timestamp < '2021-09-01 00:00:00' 
    AND status=1
    AND (call_type NOT IN ('delegatecall', 'callcode', 'staticcall') OR call_type IS null)
    
    UNION ALL
    
    SELECT from_address AS address, -value AS value
    FROM `spider2-public-data.crypto_ethereum.traces`
    WHERE from_address IS NOT null
    AND block_timestamp < '2021-09-01 00:00:00'
    AND status=1
    AND (call_type NOT IN ('delegatecall', 'callcode', 'staticcall') OR call_type IS null)
    
    UNION ALL
    
    SELECT miner as address, SUM(CAST(receipt_gas_used AS NUMERIC) * CAST(gas_price AS NUMERIC)) AS value
    FROM `spider2-public-data.crypto_ethereum.transactions` AS transactions
    JOIN `spider2-public-data.crypto_ethereum.blocks` AS blocks
    ON blocks.number = transactions.block_number
    WHERE block_timestamp < '2021-09-01 00:00:00'
    GROUP BY blocks.miner
    
    UNION ALL
    
    SELECT from_address as address, -(CAST(receipt_gas_used AS NUMERIC) * CAST(gas_price AS NUMERIC)) AS value
    FROM  `spider2-public-data.crypto_ethereum.transactions`
    WHERE block_timestamp < '2021-09-01 00:00:00'
),
a AS (
    SELECT SUM(value)/POWER(10,18) AS balance, address
    FROM value_table
    GROUP BY address
    ORDER BY balance DESC
),
b AS (
    SELECT to_address, COUNT(transactions.hash) AS tx_recipient
    FROM  `spider2-public-data.crypto_ethereum.transactions` AS transactions
    WHERE block_timestamp < '2021-09-01 00:00:00'
    GROUP BY to_address
), 
c AS (
    SELECT from_address, COUNT(transactions.hash) AS tx_sender
    FROM  `spider2-public-data.crypto_ethereum.transactions` AS transactions
    WHERE block_timestamp < '2021-09-01 00:00:00'
    GROUP BY from_address
)
SELECT balance
FROM c LEFT JOIN a ON (a.address = c.from_address)
ORDER BY tx_sender DESC
LIMIT 1