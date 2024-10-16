WITH double_entry_book AS (
  -- Debits
  SELECT 
    to_address AS address,
    value AS value
  FROM `spider2-public-data.ethereum_blockchain.traces`
  WHERE to_address IS NOT NULL
    AND status = 1
    AND (call_type NOT IN ('delegatecall', 'callcode', 'staticcall') OR call_type IS NULL)
  UNION ALL
  -- Credits
  SELECT 
    from_address AS address,
    -value AS value
  FROM `spider2-public-data.ethereum_blockchain.traces`
  WHERE from_address IS NOT NULL
    AND status = 1
    AND (call_type NOT IN ('delegatecall', 'callcode', 'staticcall') OR call_type IS NULL)
  UNION ALL
  -- Transaction fees debits
  SELECT 
    miner AS address,
    SUM(CAST(receipt_gas_used AS NUMERIC) * CAST(gas_price AS NUMERIC)) AS value
  FROM `spider2-public-data.ethereum_blockchain.transactions` AS transactions
  JOIN `spider2-public-data.ethereum_blockchain.blocks` AS blocks
  ON blocks.number = transactions.block_number
  GROUP BY blocks.miner
  UNION ALL
  -- Transaction fees credits
  SELECT 
    from_address AS address,
    -(CAST(receipt_gas_used AS NUMERIC) * CAST(gas_price AS NUMERIC)) AS value
  FROM `spider2-public-data.ethereum_blockchain.transactions`
),

top_10_balances AS (
  SELECT
    address,
    SUM(value) AS balance
  FROM double_entry_book
  GROUP BY address
  ORDER BY balance DESC
  LIMIT 10
)

SELECT 
  AVG(balance) AS average_balance
FROM top_10_balances