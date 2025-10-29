WITH tx_fees AS (
  SELECT
    t."from_address" AS sender,
    b."miner" AS miner,
    (t."receipt_gas_used" * t."gas_price") AS fee
  FROM "ETHEREUM_BLOCKCHAIN"."ETHEREUM_BLOCKCHAIN"."TRANSACTIONS" t
  JOIN "ETHEREUM_BLOCKCHAIN"."ETHEREUM_BLOCKCHAIN"."BLOCKS" b
    ON t."block_hash" = b."hash"
  WHERE t."receipt_status" = 1
),
miner_fee_income AS (
  SELECT miner AS address, SUM(fee) AS amount
  FROM tx_fees
  WHERE miner IS NOT NULL
  GROUP BY miner
),
sender_fee_deduction AS (
  SELECT sender AS address, -SUM(fee) AS amount
  FROM tx_fees
  WHERE sender IS NOT NULL
  GROUP BY sender
),
trace_inflows AS (
  SELECT
    tr."to_address" AS address,
    SUM(tr."value") AS amount
  FROM "ETHEREUM_BLOCKCHAIN"."ETHEREUM_BLOCKCHAIN"."TRACES" tr
  WHERE tr."status" = 1
    AND tr."to_address" IS NOT NULL
    AND (tr."trace_type" IS NULL OR LOWER(tr."trace_type") != 'reward')
    AND (tr."call_type" IS NULL OR LOWER(tr."call_type") NOT IN ('delegatecall','callcode','staticcall'))
  GROUP BY tr."to_address"
),
trace_outflows AS (
  SELECT
    tr."from_address" AS address,
    -SUM(tr."value") AS amount
  FROM "ETHEREUM_BLOCKCHAIN"."ETHEREUM_BLOCKCHAIN"."TRACES" tr
  WHERE tr."status" = 1
    AND tr."from_address" IS NOT NULL
    AND (tr."trace_type" IS NULL OR LOWER(tr."trace_type") != 'reward')
    AND (tr."call_type" IS NULL OR LOWER(tr."call_type") NOT IN ('delegatecall','callcode','staticcall'))
  GROUP BY tr."from_address"
),
all_flows AS (
  SELECT address, amount FROM trace_inflows
  UNION ALL
  SELECT address, amount FROM trace_outflows
  UNION ALL
  SELECT address, amount FROM miner_fee_income
  UNION ALL
  SELECT address, amount FROM sender_fee_deduction
),
net_balances AS (
  SELECT address, SUM(amount) AS net_balance
  FROM all_flows
  WHERE address IS NOT NULL
  GROUP BY address
),
top10 AS (
  SELECT address, net_balance
  FROM net_balances
  ORDER BY net_balance DESC
  LIMIT 10
)
SELECT ROUND(AVG(net_balance / POWER(10, 15)), 2) AS avg_balance_quadrillions
FROM top10;