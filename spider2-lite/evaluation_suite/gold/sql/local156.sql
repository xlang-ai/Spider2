WITH cte_dollar_cost_average AS (
  SELECT
    strftime('%Y', substr(bitcoin_transactions.txn_date, 7, 4) || '-' || substr(bitcoin_transactions.txn_date, 4, 2) || '-' || substr(bitcoin_transactions.txn_date, 1, 2)) AS year_start,
    bitcoin_members.region,
    SUM(bitcoin_transactions.quantity * bitcoin_prices.price) / SUM(bitcoin_transactions.quantity) AS btc_dca
  FROM bitcoin_transactions
  INNER JOIN bitcoin_prices
    ON bitcoin_transactions.ticker = bitcoin_prices.ticker
    AND bitcoin_transactions.txn_date = bitcoin_prices.market_date
  INNER JOIN bitcoin_members
    ON bitcoin_transactions.member_id = bitcoin_members.member_id
  WHERE bitcoin_transactions.ticker = 'BTC'
    AND bitcoin_transactions.txn_type = 'BUY'
  GROUP BY year_start, bitcoin_members.region
),

cte_window_functions AS (
  SELECT
    year_start,
    region,
    btc_dca,
    (SELECT COUNT(*) 
     FROM cte_dollar_cost_average AS sub
     WHERE sub.year_start = cte_dollar_cost_average.year_start 
       AND sub.btc_dca <= cte_dollar_cost_average.btc_dca) AS dca_ranking,
    (SELECT btc_dca 
     FROM cte_dollar_cost_average AS sub
     WHERE sub.region = cte_dollar_cost_average.region 
       AND sub.year_start < cte_dollar_cost_average.year_start
     ORDER BY sub.year_start DESC
     LIMIT 1) AS previous_btc_dca,
     ROW_NUMBER() OVER (PARTITION BY region ORDER BY year_start) AS rn
  FROM cte_dollar_cost_average
)

SELECT
  year_start,
  region,
  ROUND(btc_dca, 2) AS btc_dca,
  dca_ranking,
  ROUND(
    100.0 * (btc_dca - previous_btc_dca) / previous_btc_dca,
    2
  ) AS dca_percentage_change
FROM cte_window_functions
WHERE rn > 1
ORDER BY region, year_start;
