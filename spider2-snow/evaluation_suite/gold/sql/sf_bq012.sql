WITH double_entry_book AS (
  -- Debits
  SELECT 
    "to_address" AS "address",
    "value" AS "value"
  FROM "ETHEREUM_BLOCKCHAIN"."ETHEREUM_BLOCKCHAIN"."TRACES"
  WHERE "to_address" IS NOT NULL
    AND "status" = 1
    AND ("call_type" NOT IN ('delegatecall', 'callcode', 'staticcall') OR "call_type" IS NULL)
  
  UNION ALL
  
  -- Credits
  SELECT 
    "from_address" AS "address",
    - "value" AS "value"
  FROM "ETHEREUM_BLOCKCHAIN"."ETHEREUM_BLOCKCHAIN"."TRACES"
  WHERE "from_address" IS NOT NULL
    AND "status" = 1
    AND ("call_type" NOT IN ('delegatecall', 'callcode', 'staticcall') OR "call_type" IS NULL)
  
  UNION ALL
  
  -- Transaction fees debits
  SELECT 
    "miner" AS "address",
    SUM(CAST("receipt_gas_used" AS NUMBER) * CAST("gas_price" AS NUMBER)) AS "value"
  FROM "ETHEREUM_BLOCKCHAIN"."ETHEREUM_BLOCKCHAIN"."TRANSACTIONS" AS "transactions"
  JOIN "ETHEREUM_BLOCKCHAIN"."ETHEREUM_BLOCKCHAIN"."BLOCKS" AS "blocks"
    ON "blocks"."number" = "transactions"."block_number"
  GROUP BY "blocks"."miner"
  
  UNION ALL
  
  -- Transaction fees credits
  SELECT 
    "from_address" AS "address",
    -(CAST("receipt_gas_used" AS NUMBER) * CAST("gas_price" AS NUMBER)) AS "value"
  FROM "ETHEREUM_BLOCKCHAIN"."ETHEREUM_BLOCKCHAIN"."TRANSACTIONS"
),
top_10_balances AS (
  SELECT
    "address",
    SUM("value") AS "balance"
  FROM double_entry_book
  GROUP BY "address"
  ORDER BY "balance" DESC
  LIMIT 10
)
SELECT 
    ROUND(AVG("balance") / 1e15, 2) AS "average_balance_trillion"
FROM top_10_balances;
