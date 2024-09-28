WITH activity_log_with_lead_path AS (
  SELECT
    session,
    stamp,
    path AS path0,
    COALESCE(LEAD(path, 1) OVER(PARTITION BY session ORDER BY stamp ASC), 'END') AS path1,
    COALESCE(LEAD(path, 2) OVER(PARTITION BY session ORDER BY stamp ASC), 'END') AS path2
  FROM
    activity_log
),
raw_user_flow AS (
  SELECT
    path0,
    SUM(COUNT(1)) OVER() AS count0,
    path1,
    SUM(COUNT(1)) OVER(PARTITION BY path0, path1) AS count1,
    path2,
    COUNT(1) AS count2
  FROM
    activity_log_with_lead_path
  WHERE
    path0 = '/detail'
  GROUP BY
    path0, path1, path2
),
ranked_user_flow AS (
  SELECT
    path0,
    count0,
    path1,
    count1,
    path2,
    count2,
    LAG(path0) OVER(ORDER BY count1 DESC, count2 DESC) AS prev_path0,
    LAG(path0 || path1) OVER(ORDER BY count1 DESC, count2 DESC) AS prev_path0_path1,
    LAG(path0 || path1 || path2) OVER(ORDER BY count1 DESC, count2 DESC) AS prev_path0_path1_path2
  FROM
    raw_user_flow
)
SELECT
  path2,
  count2
FROM
  ranked_user_flow
WHERE
  path0 = '/detail' AND path1 = '/detail'
ORDER BY
  count2 DESC
LIMIT 3;