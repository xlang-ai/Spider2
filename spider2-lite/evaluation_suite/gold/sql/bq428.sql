WITH top_teams AS (
  SELECT
    team_market
  FROM (
    SELECT
      team_market,
      player_id AS id,
      SUM(points_scored)
    FROM
      `bigquery-public-data.ncaa_basketball.mbb_pbp_sr`
    WHERE
      season >= 2010 AND season <=2018 AND period = 2
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
    COUNT(DISTINCT id) DESC
  LIMIT 5
)


SELECT
  season,
  round,
  days_from_epoch,
  game_date,
  day,
  'win' AS label,
  win_seed AS seed,
  win_market AS market,
  win_name AS name,
  win_alias AS alias,
  win_school_ncaa AS school_ncaa,
  lose_seed AS opponent_seed,
  lose_market AS opponent_market,
  lose_name AS opponent_name,
  lose_alias AS opponent_alias,
  lose_school_ncaa AS opponent_school_ncaa
FROM `bigquery-public-data.ncaa_basketball.mbb_historical_tournament_games`
JOIN top_teams ON top_teams.team_market = win_market
WHERE season >= 2010 AND season <=2018

UNION ALL

SELECT
  season,
  round,
  days_from_epoch,
  game_date,
  day,
  'loss' AS label,
  lose_seed AS seed,
  lose_market AS market,
  lose_name AS name,
  lose_alias AS alias,
  lose_school_ncaa AS school_ncaa,
  win_seed AS opponent_seed,
  win_market AS opponent_market,
  win_name AS opponent_name,
  win_alias AS opponent_alias,
  win_school_ncaa AS opponent_school_ncaa
FROM `bigquery-public-data.ncaa_basketball.mbb_historical_tournament_games`
JOIN top_teams ON top_teams.team_market = lose_market
WHERE season >= 2010 AND season <=2018
