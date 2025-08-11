SELECT
  team_name,
  COUNT(*) AS top_performer_count
FROM (
  SELECT
    DISTINCT c2.season,
    c2.market AS team_name
  FROM (
    SELECT
      season AS a,
      MAX(wins) AS win_max
    FROM
      `bigquery-public-data.ncaa_basketball.mbb_historical_teams_seasons`
    WHERE
      season<=2000
      AND season >=1900
    GROUP BY
      season ),
    `bigquery-public-data.ncaa_basketball.mbb_historical_teams_seasons` c2
  WHERE
    win_max = c2.wins
    AND a = c2.season
    AND c2.market IS NOT NULL
  ORDER BY
    c2.season)
GROUP BY
  team_name
ORDER BY
  top_performer_count DESC,
  team_name
LIMIT
  5