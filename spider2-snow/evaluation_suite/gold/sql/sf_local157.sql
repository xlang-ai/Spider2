WITH cte_adjusted_prices AS (
  SELECT
    "ticker",
    "market_date",
    CASE
      WHEN SUBSTRING("volume", -1) = 'K' THEN CAST(SUBSTRING("volume", 1, LENGTH("volume") - 1) AS REAL) * 1000
      WHEN SUBSTRING("volume", -1) = 'M' THEN CAST(SUBSTRING("volume", 1, LENGTH("volume") - 1) AS REAL) * 1000000
      WHEN "volume" = '-' THEN 0
      ELSE CAST("volume" AS REAL)
    END AS volume
  FROM "BANK_SALES_TRADING"."BANK_SALES_TRADING"."BITCOIN_PRICES"
),
cte_previous_volume AS (
  SELECT
    "ticker",
    "market_date",
    volume,
    LAG(volume) OVER (
      PARTITION BY "ticker"
      ORDER BY TO_DATE(SUBSTRING("market_date", 7, 4) || '-' || SUBSTRING("market_date", 4, 2) || '-' || SUBSTRING("market_date", 1, 2), 'YYYY-MM-DD')
    ) AS previous_volume
  FROM cte_adjusted_prices
  WHERE volume != 0
)
SELECT
  "ticker",
  "market_date",
  volume,
  previous_volume,
  ROUND(
    100.0 * (volume - previous_volume) / previous_volume,
    2
  ) AS daily_change
FROM cte_previous_volume
WHERE TO_DATE(SUBSTRING("market_date", 7, 4) || '-' || SUBSTRING("market_date", 4, 2) || '-' || SUBSTRING("market_date", 1, 2), 'YYYY-MM-DD')
  BETWEEN TO_DATE('2021-08-01', 'YYYY-MM-DD') AND TO_DATE('2021-08-10', 'YYYY-MM-DD')
ORDER BY "ticker", "market_date";
