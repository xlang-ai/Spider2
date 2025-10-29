WITH inflows AS (
  SELECT 
    "to_address" AS address,
    SUM(CAST("value" AS NUMBER)) AS total_received
  FROM "ETHEREUM_BLOCKCHAIN"."ETHEREUM_BLOCKCHAIN"."TOKEN_TRANSFERS"
  WHERE "token_address" = '0xb8c77482e45f1f44de1745f52c74426c631bdd52'
    AND "to_address" != '0x0000000000000000000000000000000000000000'
  GROUP BY "to_address"
),
outflows AS (
  SELECT 
    "from_address" AS address,
    SUM(CAST("value" AS NUMBER)) AS total_sent
  FROM "ETHEREUM_BLOCKCHAIN"."ETHEREUM_BLOCKCHAIN"."TOKEN_TRANSFERS"
  WHERE "token_address" = '0xb8c77482e45f1f44de1745f52c74426c631bdd52'
    AND "from_address" != '0x0000000000000000000000000000000000000000'
  GROUP BY "from_address"
),
all_addresses AS (
  SELECT address FROM inflows
  UNION
  SELECT address FROM outflows
),
net_balances AS (
  SELECT 
    aa.address,
    COALESCE(i.total_received, 0) - COALESCE(o.total_sent, 0) AS balance
  FROM all_addresses aa
  LEFT JOIN inflows i ON aa.address = i.address
  LEFT JOIN outflows o ON aa.address = o.address
)
SELECT 
  SUM(CASE WHEN balance > 0 THEN balance ELSE 0 END) / POWER(10, 18) AS total_circulating_supply
FROM net_balances