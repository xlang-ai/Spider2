WITH ytd_performance AS (
  SELECT
    ticker,
    MIN(date) OVER (PARTITION BY ticker) AS start_of_year_date,
    FIRST_VALUE(value) OVER (PARTITION BY ticker ORDER BY date ASC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS start_of_year_price,
    MAX(date) OVER (PARTITION BY ticker) AS latest_date,
    LAST_VALUE(value) OVER (PARTITION BY ticker ORDER BY date ASC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS latest_price
  FROM FINANCE__ECONOMICS.CYBERSYN.stock_price_timeseries
  WHERE
    ticker IN ('AAPL', 'MSFT', 'AMZN', 'GOOGL', 'META', 'TSLA', 'NVDA')
    AND date BETWEEN DATE '2024-01-01' AND DATE '2024-06-30'  -- Adjusted to cover only from the start of 2024 to the end of June 2024
    AND variable_name = 'Post-Market Close'
)
SELECT
  ticker,
  (latest_price - start_of_year_price) / start_of_year_price * 100 AS percentage_change_ytd
FROM
  ytd_performance
GROUP BY
  ticker, start_of_year_date, start_of_year_price, latest_date, latest_price
ORDER BY percentage_change_ytd DESC;