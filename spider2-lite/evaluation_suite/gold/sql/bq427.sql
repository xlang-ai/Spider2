WITH ShotsWithScoreDelta AS (
  SELECT 
    shot_type,
    CASE 
      WHEN score_delta < -20 THEN '<-20'
      WHEN score_delta >= -20 AND score_delta < -10 THEN '-20 — -11'
      WHEN score_delta >= -10 AND score_delta < 0 THEN '-10 — -1'
      WHEN score_delta = 0 THEN '0'
      WHEN score_delta >= 1 AND score_delta <= 10 THEN '1 — 10'
      WHEN score_delta > 10 AND score_delta <= 20 THEN '11 — 20'
      WHEN score_delta > 20 THEN '>20'
    END AS score_delta_interval,
    IF(event_coord_x < 564, CAST(event_coord_x AS INT64), 1128 - CAST(event_coord_x AS INT64)) AS x,
    IF(event_coord_x < 564, 600 - CAST(event_coord_y AS INT64), CAST(event_coord_y AS INT64)) AS y,
    COUNT(*) AS attempts,
    COUNTIF(points_scored IS NOT NULL) AS successes
  FROM (
    SELECT 
      event_coord_x, event_coord_y, points_scored, shot_type, team_basket, scheduled_date,
      SUM(IFNULL(CAST(points_scored AS INT64), 0)) OVER (PARTITION BY game_id, team_id ORDER BY timestamp) AS team_score,
      SUM(IFNULL(CAST(points_scored AS INT64), 0)) OVER (PARTITION BY game_id ORDER BY timestamp) AS game_score,
      -- Calculate score_delta
      SUM(IFNULL(CAST(points_scored AS INT64), 0)) OVER (PARTITION BY game_id, team_id ORDER BY timestamp)
        - SUM(IFNULL(CAST(points_scored AS INT64), 0)) OVER (PARTITION BY game_id ORDER BY timestamp) AS score_delta
    FROM `bigquery-public-data.ncaa_basketball.mbb_pbp_sr`
  )
  WHERE 
    shot_type IS NOT NULL
    AND event_coord_x IS NOT NULL
    AND event_coord_y IS NOT NULL
    AND scheduled_date < '2018-03-15'
    AND IF(event_coord_x < 564, 'left', 'right') = team_basket
  GROUP BY shot_type, score_delta_interval, x, y
),

MostFrequentScoreDelta AS (
  SELECT 
    shot_type,
    score_delta_interval,
    COUNT(*) AS attempts
  FROM ShotsWithScoreDelta
  GROUP BY shot_type, score_delta_interval
  ORDER BY shot_type, attempts DESC
),

FinalResult AS (
  SELECT 
    S.shot_type,
    AVG(S.x) AS avg_x,
    AVG(S.y) AS avg_y,
    AVG(S.attempts) AS avg_attempts,
    AVG(S.successes) AS avg_successes
  FROM ShotsWithScoreDelta S
  INNER JOIN MostFrequentScoreDelta M 
    ON S.shot_type = M.shot_type
    AND S.score_delta_interval = M.score_delta_interval
  GROUP BY S.shot_type
)

SELECT * FROM FinalResult
ORDER BY avg_attempts DESC;