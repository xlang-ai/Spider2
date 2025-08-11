WITH 

visit AS (
SELECT fullvisitorid, MIN(date) AS date_first_visit, MAX(date) AS date_last_visit 
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*` GROUP BY fullvisitorid),

device_visit AS (
SELECT DISTINCT fullvisitorid, date, device.deviceCategory
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`),

transactions AS (
SELECT fullvisitorid, MIN(date) AS date_transactions, 1 AS transaction
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*` AS ga, UNNEST(ga.hits) AS hits
WHERE  hits.transaction.transactionId IS NOT NULL GROUP BY fullvisitorid),

device_transactions AS (
SELECT DISTINCT fullvisitorid, date, device.deviceCategory
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*` AS ga, UNNEST(ga.hits) AS hits
WHERE hits.transaction.transactionId IS NOT NULL),

visits_transactions AS (
SELECT visit.fullvisitorid, date_first_visit, date_transactions, date_last_visit , 
       device_visit.deviceCategory AS device_last_visit, device_transactions.deviceCategory AS device_transaction, 
       IFNULL(transactions.transaction,0) AS transaction
FROM visit LEFT JOIN transactions ON visit.fullvisitorid = transactions.fullvisitorid
LEFT JOIN device_visit ON visit.fullvisitorid = device_visit.fullvisitorid 
AND visit.date_last_visit = device_visit.date

LEFT JOIN device_transactions ON visit.fullvisitorid = device_transactions.fullvisitorid 
AND transactions.date_transactions = device_transactions.date ),

mortality_table AS (
SELECT fullvisitorid, date_first_visit, 
       CASE WHEN date_transactions IS NULL THEN date_last_visit ELSE date_transactions  END AS date_event, 
       CASE WHEN device_transaction IS NULL THEN device_last_visit ELSE device_transaction END AS device, transaction
FROM visits_transactions )

SELECT DATE_DIFF(PARSE_DATE('%Y%m%d',date_event), PARSE_DATE('%Y%m%d', date_first_visit),DAY) AS time 
FROM mortality_table
WHERE device = 'mobile'
ORDER BY DATE_DIFF(PARSE_DATE('%Y%m%d',date_event), PARSE_DATE('%Y%m%d', date_first_visit),DAY) DESC
LIMIT 1