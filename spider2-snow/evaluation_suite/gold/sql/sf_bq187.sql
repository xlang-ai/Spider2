WITH tokenInfo AS (
    SELECT "address"
    FROM "ETHEREUM_BLOCKCHAIN"."ETHEREUM_BLOCKCHAIN"."TOKENS"
    WHERE "name" = 'BNB'
),

receivedTx AS (
    SELECT "tx"."to_address" AS "addr", 
           "tokens"."name" AS "name", 
           SUM(CAST("tx"."value" AS FLOAT) / POWER(10, 18)) AS "amount_received"
    FROM "ETHEREUM_BLOCKCHAIN"."ETHEREUM_BLOCKCHAIN"."TOKEN_TRANSFERS" AS "tx"
    JOIN tokenInfo ON "tx"."token_address" = tokenInfo."address"
    JOIN "ETHEREUM_BLOCKCHAIN"."ETHEREUM_BLOCKCHAIN"."TOKENS" AS "tokens"
      ON "tx"."token_address" = "tokens"."address"
    WHERE "tx"."to_address" <> '0x0000000000000000000000000000000000000000'
    GROUP BY "tx"."to_address", "tokens"."name"
),

sentTx AS (
    SELECT "tx"."from_address" AS "addr", 
           "tokens"."name" AS "name", 
           SUM(CAST("tx"."value" AS FLOAT) / POWER(10, 18)) AS "amount_sent"
    FROM "ETHEREUM_BLOCKCHAIN"."ETHEREUM_BLOCKCHAIN"."TOKEN_TRANSFERS" AS "tx"
    JOIN tokenInfo ON "tx"."token_address" = tokenInfo."address"
    JOIN "ETHEREUM_BLOCKCHAIN"."ETHEREUM_BLOCKCHAIN"."TOKENS" AS "tokens"
      ON "tx"."token_address" = "tokens"."address"
    WHERE "tx"."from_address" <> '0x0000000000000000000000000000000000000000'
    GROUP BY "tx"."from_address", "tokens"."name"
),

walletBalances AS (
    SELECT r."addr",
           COALESCE(SUM(r."amount_received"), 0) - COALESCE(SUM(s."amount_sent"), 0) AS "balance"
    FROM receivedTx AS r
    LEFT JOIN sentTx AS s
      ON r."addr" = s."addr"
    GROUP BY r."addr"
)

SELECT 
    SUM("balance") AS "circulating_supply"
FROM walletBalances;
