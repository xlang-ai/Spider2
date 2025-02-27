SELECT
  OrderID AS tradeID,
  MaturityDate AS tradeTimestamp,
  (
    CASE SUBSTR(TargetCompID, 0, 4)
      WHEN 'MOMO' THEN 'Momentum'
      WHEN 'LUCK' THEN 'Feeling Lucky'
      WHEN 'PRED' THEN 'Prediction'
  END
    ) AS algorithm,
  Symbol AS symbol,
  LastPx AS openPrice,
  StrikePrice AS closePrice,
  (
  SELECT
    Side
  FROM
    UNNEST(Sides)
  ) AS tradeDirection,
  (CASE (
    SELECT
      Side
    FROM
      UNNEST(Sides))
      WHEN 'SHORT' THEN -1
      WHEN 'LONG' THEN 1
  END
    ) AS tradeMultiplier
FROM
  `bigquery-public-data.cymbal_investments.trade_capture_report`cv
ORDER BY closePrice DESC
LIMIT 6