WITH MomentumTrades AS (
  SELECT
    StrikePrice - LastPx AS priceDifference
  FROM
    `bigquery-public-data.cymbal_investments.trade_capture_report`
  WHERE
    SUBSTR(TargetCompID, 0, 4) = 'MOMO'
    AND (SELECT Side FROM UNNEST(Sides)) = 'LONG'
),

FeelingLuckyTrades AS (
  SELECT
    StrikePrice - LastPx AS priceDifference
  FROM
    `bigquery-public-data.cymbal_investments.trade_capture_report`
  WHERE
    SUBSTR(TargetCompID, 0, 4) = 'LUCK'
    AND (SELECT Side FROM UNNEST(Sides)) = 'LONG'
)

SELECT
  AVG(FeelingLuckyTrades.priceDifference) - AVG(MomentumTrades.priceDifference) AS averageDifference 
FROM
  MomentumTrades,
  FeelingLuckyTrades