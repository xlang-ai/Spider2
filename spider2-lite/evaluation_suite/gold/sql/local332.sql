WITH activity_log_with_fallout_step AS (
  SELECT
    session,
    path,
    MAX(stamp) AS session_end,
    MIN(stamp) AS session_start
  FROM
    activity_log
  GROUP BY
    session
),
longest_session AS (
  SELECT
    session,
    strftime('%s', session_end) - strftime('%s', session_start) AS time_spent_seconds
  FROM
    activity_log_with_fallout_step
  ORDER BY
    time_spent_seconds DESC
  LIMIT 3
)
SELECT
  SESSION, 
  time_spent_seconds
FROM
  longest_session;