WITH filtered_data AS (
  SELECT
    fullVisitorId,
    bounces,
    time_on_site,
    will_buy_on_return_visit
  FROM (
        # select features
        SELECT
          fullVisitorId,
          IFNULL(totals.bounces, 0) AS bounces,
          IFNULL(totals.timeOnSite, 0) AS time_on_site
        FROM
          `bigquery-public-data.google_analytics_sample.*`
        WHERE
          totals.newVisits = 1
        AND date BETWEEN '20160801'
        AND '20170430'
       )
  JOIN (
        SELECT
          fullvisitorid,
          IF (
              COUNTIF (
                       totals.transactions > 0
                       AND totals.newVisits IS NULL
                      ) > 0,
              1,
              0
             ) AS will_buy_on_return_visit
        FROM
          `bigquery-public-data.google_analytics_sample.*`
        GROUP BY
          fullvisitorid
       )
  USING (fullVisitorId)
  ORDER BY time_on_site DESC
)
SELECT
  SAFE_DIVIDE(
    COUNTIF(time_on_site > 300 AND will_buy_on_return_visit = 1),
    COUNT(*)
  ) * 100 AS proportion_of_users
FROM
  filtered_data;
