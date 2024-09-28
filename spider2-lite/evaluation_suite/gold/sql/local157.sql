WITH cte_adjusted_prices AS (
  SELECT
    ticker,
    market_date,
    CASE
      WHEN substr(volume, -1) = 'K' THEN cast(substr(volume, 1, length(volume) - 1) AS REAL) * 1000
      WHEN substr(volume, -1) = 'M' THEN cast(substr(volume, 1, length(volume) - 1) AS REAL) * 1000000
      WHEN volume = '-' THEN 0
      ELSE cast(volume AS REAL)
    END AS volume
  FROM bitcoin_prices
),
cte_previous_volume AS (
  SELECT
    ticker,
    market_date,
    volume,
    LAG(volume) OVER (
      PARTITION BY ticker
      ORDER BY strftime('%Y-%m-%d', substr(market_date, 7, 4) || '-' || substr(market_date, 4, 2) || '-' || substr(market_date, 1, 2))
    ) AS previous_volume
  FROM cte_adjusted_prices
  WHERE volume != 0
)
SELECT
  ticker,
  market_date,
  volume,
  previous_volume,
  ROUND(
    100.0 * (volume - previous_volume) / previous_volume,
    2
  ) AS daily_change
FROM cte_previous_volume
WHERE strftime('%Y-%m-%d', substr(market_date, 7, 4) || '-' || substr(market_date, 4, 2) || '-' || substr(market_date, 1, 2))
  BETWEEN '2021-08-01' AND '2021-08-10'
ORDER BY ticker, market_date;
