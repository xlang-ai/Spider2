WITH "merged_union" AS (
  SELECT
    "block_timestamp",
    "value",
    'output' AS "origin"
  FROM "CRYPTO"."CRYPTO_BITCOIN"."OUTPUTS"
  UNION ALL
  SELECT
    "block_timestamp",
    "value",
    'input' AS "origin"
  FROM "CRYPTO"."CRYPTO_BITCOIN"."INPUTS"
),
"merged_outputs_avg" AS (
  SELECT
    DATE_PART(year, TO_TIMESTAMP_NTZ("block_timestamp", 6)) AS "year",
    AVG("value") AS "merged_avg"
  FROM "merged_union"
  WHERE "origin" = 'output'
    AND "value" IS NOT NULL
    AND "block_timestamp" IS NOT NULL
  GROUP BY 1
),
"transactions_avg" AS (
  SELECT
    DATE_PART(year, TO_TIMESTAMP_NTZ("block_timestamp", 6)) AS "year",
    AVG("output_value") AS "tx_avg"
  FROM "CRYPTO"."CRYPTO_BITCOIN"."TRANSACTIONS"
  WHERE "output_value" IS NOT NULL
    AND "block_timestamp" IS NOT NULL
  GROUP BY 1
)
SELECT
  m."year",
  m."merged_avg" - t."tx_avg" AS "difference"
FROM "merged_outputs_avg" m
JOIN "transactions_avg" t
  ON m."year" = t."year"
ORDER BY m."year";