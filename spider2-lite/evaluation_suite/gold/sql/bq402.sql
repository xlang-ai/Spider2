WITH visitors AS (
  SELECT
    COUNT(DISTINCT fullVisitorId) AS total_visitors
  FROM 
    `data-to-insights.ecommerce.web_analytics`
),

purchasers AS (
  SELECT
    COUNT(DISTINCT fullVisitorId) AS total_purchasers
  FROM 
    `data-to-insights.ecommerce.web_analytics`
  WHERE 
    totals.transactions IS NOT NULL
),

transactions AS (
  SELECT
    COUNT(*) AS total_transactions,
    AVG(totals.transactions) AS avg_transactions_per_purchaser
  FROM 
    `data-to-insights.ecommerce.web_analytics`
  WHERE 
    totals.transactions IS NOT NULL
)

SELECT
  p.total_purchasers / v.total_visitors AS conversion_rate,
  a.avg_transactions_per_purchaser AS avg_transactions_per_purchaser
FROM
  visitors v,
  purchasers p,
  transactions a;