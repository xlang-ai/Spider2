WITH 
  visit AS (
    SELECT fullvisitorid, MIN(date) AS date_first_visit
    FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*` 
    GROUP BY fullvisitorid
  ),
  
  transactions AS (
    SELECT fullvisitorid, MIN(date) AS date_transactions, 1 AS transaction
    FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*` AS ga, 
    UNNEST(ga.hits) AS hits 
    WHERE hits.transaction.transactionId IS NOT NULL 
    GROUP BY fullvisitorid
  ),

  device_transactions AS (
    SELECT DISTINCT fullvisitorid, date, device.deviceCategory AS device_transaction
    FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*` AS ga, 
    UNNEST(ga.hits) AS hits 
    WHERE hits.transaction.transactionId IS NOT NULL
  ),

  visits_transactions AS (
    SELECT visit.fullvisitorid, date_first_visit, date_transactions, device_transaction
    FROM visit 
    LEFT JOIN transactions ON visit.fullvisitorid = transactions.fullvisitorid
    LEFT JOIN device_transactions ON visit.fullvisitorid = device_transactions.fullvisitorid 
    AND transactions.date_transactions = device_transactions.date
  )

SELECT fullvisitorid 
FROM visits_transactions
WHERE DATE_DIFF(PARSE_DATE('%Y%m%d', date_transactions), PARSE_DATE('%Y%m%d', date_first_visit), DAY) > 0
AND device_transaction = "mobile";