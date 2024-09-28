SELECT
  team_market,
  COUNT(DISTINCT id) AS num_players
FROM (
  SELECT
    team_market,
    player_id AS id,
    SUM(points_scored)
  FROM
    `bigquery-public-data.ncaa_basketball.mbb_pbp_sr`
  WHERE
    (period = 2)
  GROUP BY
    game_id,
    team_market,
    player_id
  HAVING
    SUM(points_scored) >= 15) C
GROUP BY
  team_market
HAVING
  COUNT(DISTINCT id) > 5
ORDER BY
  COUNT(DISTINCT id) DESC,
  team_market
LIMIT 5;