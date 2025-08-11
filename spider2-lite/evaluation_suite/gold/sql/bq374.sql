WITH initial_visits AS (
    SELECT
        fullVisitorId,
        MIN(visitStartTime) AS initialVisitStartTime
    FROM
        `bigquery-public-data.google_analytics_sample.*`
    WHERE
        totals.newVisits = 1
        AND date BETWEEN '20160801' AND '20170430'
    GROUP BY
        fullVisitorId
),
qualified_initial_visits AS (
  SELECT
    s.fullVisitorId,
    s.visitStartTime AS initialVisitStartTime,
    s.totals.timeOnSite AS time_on_site
  FROM
    `bigquery-public-data.google_analytics_sample.*` s
  JOIN initial_visits i
    ON s.fullVisitorId = i.fullVisitorId
    AND s.visitStartTime = i.initialVisitStartTime
  WHERE
    s.totals.timeOnSite > 300
),
filtered_data AS (
  SELECT
    q.fullVisitorId,
    q.time_on_site,
    IF(COUNTIF(s.visitStartTime > q.initialVisitStartTime AND s.totals.transactions > 0) > 0, 1, 0) AS will_buy_on_return_visit
  FROM
    qualified_initial_visits q
  LEFT JOIN `bigquery-public-data.google_analytics_sample.*` s
    ON q.fullVisitorId = s.fullVisitorId
  GROUP BY
    q.fullVisitorId, q.time_on_site
),
matching_users AS (
  SELECT
    fullVisitorId
  FROM
    filtered_data
  WHERE
    time_on_site > 300 AND will_buy_on_return_visit = 1
),
total_new_users AS (
  SELECT
    COUNT(DISTINCT fullVisitorId) AS total_new_users
  FROM
    `bigquery-public-data.google_analytics_sample.*`
  WHERE
    totals.newVisits = 1
    AND date BETWEEN '20160801' AND '20170430'
),
final_counts AS (
  SELECT
    COUNT(DISTINCT fullVisitorId) AS users_matching_criteria
  FROM
    matching_users
)
SELECT
  (final_counts.users_matching_criteria / total_new_users.total_new_users) * 100 AS percentage_matching_criteria
FROM
  final_counts,
  total_new_users;
