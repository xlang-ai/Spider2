WITH
--List of users who installed
sept_cohort AS (
  SELECT DISTINCT user_pseudo_id,
  FORMAT_DATE('%Y-%m-%d', PARSE_DATE('%Y%m%d', event_date)) AS date_first_open,
  FROM `firebase-public-project.analytics_153293282.events_*`
  WHERE event_name = 'first_open'
  AND _TABLE_SUFFIX BETWEEN '20180801' and '20180930'
),
--Get the list of users who uninstalled
uninstallers AS (
  SELECT DISTINCT user_pseudo_id,
  FORMAT_DATE('%Y-%m-%d', PARSE_DATE('%Y%m%d', event_date)) AS date_app_remove,
  FROM `firebase-public-project.analytics_153293282.events_*`
  WHERE event_name = 'app_remove'
  AND _TABLE_SUFFIX BETWEEN '20180801' and '20180930'
),
--Join the 2 tables and compute for # of days to uninstall
joined AS (
  SELECT a.*,
  b.date_app_remove,
  DATE_DIFF(DATE(b.date_app_remove), DATE(a.date_first_open), DAY) AS days_to_uninstall
  FROM sept_cohort a
  LEFT JOIN uninstallers b
  ON a.user_pseudo_id = b.user_pseudo_id
)
--Compute for the percentage
SELECT
COUNT(DISTINCT
CASE WHEN days_to_uninstall > 7 OR days_to_uninstall IS NULL THEN user_pseudo_id END) /
COUNT(DISTINCT user_pseudo_id)
AS percent_users_7_days
FROM joined
