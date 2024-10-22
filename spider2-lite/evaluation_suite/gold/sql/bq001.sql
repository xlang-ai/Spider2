DECLARE start_date STRING DEFAULT '20170201';
DECLARE end_date STRING DEFAULT '20170228';

WITH visit AS (
    SELECT
        fullvisitorid,
        MIN(date) AS date_first_visit
    FROM
        `bigquery-public-data.google_analytics_sample.ga_sessions_*`
    WHERE
       _TABLE_SUFFIX BETWEEN start_date AND end_date
    GROUP BY fullvisitorid
),

transactions AS (
    SELECT
        fullvisitorid,
        MIN(date) AS date_transactions
    FROM
        `bigquery-public-data.google_analytics_sample.ga_sessions_*` AS ga,
        UNNEST(ga.hits) AS hits
    WHERE
        hits.transaction.transactionId IS NOT NULL
        AND
        _TABLE_SUFFIX BETWEEN start_date AND end_date
    GROUP BY fullvisitorid
),

device_transactions AS (
    SELECT DISTINCT
        fullvisitorid,
        date,
        device.deviceCategory
    FROM
        `bigquery-public-data.google_analytics_sample.ga_sessions_*` AS ga,
        UNNEST(ga.hits) AS hits
    WHERE
        hits.transaction.transactionId IS NOT NULL
        AND
        _TABLE_SUFFIX BETWEEN start_date AND end_date
),

visits_transactions AS (
    SELECT
        visit.fullvisitorid,
        date_first_visit,
        date_transactions,
        device_transactions.deviceCategory AS device_transaction
    FROM
        visit
        JOIN transactions
        ON visit.fullvisitorid = transactions.fullvisitorid
        JOIN device_transactions
        ON visit.fullvisitorid = device_transactions.fullvisitorid 
        AND transactions.date_transactions = device_transactions.date
)

SELECT
       fullvisitorid,
       DATE_DIFF(PARSE_DATE('%Y%m%d', date_transactions), PARSE_DATE('%Y%m%d', date_first_visit), DAY) AS time,
       device_transaction
FROM visits_transactions
ORDER BY fullvisitorid;