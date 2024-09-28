WITH tmp AS (
  SELECT DISTINCT *
  FROM `data-to-insights.ecommerce.rev_transactions`
  -- Removing duplicated values
),
tmp1 AS (
  SELECT 
    tmp.channelGrouping,
    tmp.geoNetwork_country,
    SUM(tmp.totals_transactions) AS tt
  FROM tmp
  GROUP BY 1, 2
),
tmp2 AS (
  SELECT 
    channelGrouping,
    geoNetwork_country,
    SUM(tt) AS TotalTransaction,
    COUNT(DISTINCT geoNetwork_country) OVER (PARTITION BY channelGrouping) AS CountryCount
  FROM tmp1
  GROUP BY channelGrouping, geoNetwork_country
),
tmp3 AS (
  SELECT
    channelGrouping,
    geoNetwork_country AS Country,
    TotalTransaction,
    RANK() OVER (PARTITION BY channelGrouping ORDER BY TotalTransaction DESC) AS rnk
  FROM tmp2
  WHERE CountryCount > 1
)
SELECT
  channelGrouping,
  Country,
  TotalTransaction
FROM tmp3
WHERE rnk = 1;