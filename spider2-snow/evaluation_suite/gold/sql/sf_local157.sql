WITH "parsed_volume" AS (
  SELECT
    "ticker",
    TO_DATE("market_date", 'DD-MM-YYYY') AS "market_date",
    CASE
      WHEN "volume" = '-' THEN 0
      WHEN RIGHT("volume", 1) = 'K' THEN CAST(REPLACE("volume", 'K', '') AS FLOAT) * 1000
      WHEN RIGHT("volume", 1) = 'M' THEN CAST(REPLACE("volume", 'M', '') AS FLOAT) * 1000000
      ELSE CAST("volume" AS FLOAT)
    END AS "volume_cleaned"
  FROM "BANK_SALES_TRADING"."BANK_SALES_TRADING"."BITCOIN_PRICES"
  WHERE TO_DATE("market_date", 'DD-MM-YYYY') BETWEEN '2021-08-01' AND '2021-08-10'
),
"lagged_volume" AS (
  SELECT
    "ticker",
    "market_date",
    "volume_cleaned",
    LAG(IFF("volume_cleaned" = 0, NULL, "volume_cleaned"), 1) IGNORE NULLS OVER (PARTITION BY "ticker" ORDER BY "market_date") AS "previous_day_volume"
  FROM "parsed_volume"
)
SELECT
  "ticker",
  "market_date",
  ("volume_cleaned" - "previous_day_volume") / "previous_day_volume" * 100 AS "volume_percentage_change"
FROM "lagged_volume"
ORDER BY "ticker", "market_date";