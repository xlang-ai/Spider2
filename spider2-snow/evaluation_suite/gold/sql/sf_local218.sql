WITH team_goals_by_season AS (
  -- Get goals scored by each team in each season (as home team)
  SELECT 
    "home_team_api_id" AS "team_api_id",
    "season",
    SUM("home_team_goal") AS "goals"
  FROM "EU_SOCCER"."EU_SOCCER"."MATCH"
  GROUP BY "home_team_api_id", "season"
  
  UNION ALL
  
  -- Get goals scored by each team in each season (as away team)
  SELECT 
    "away_team_api_id" AS "team_api_id",
    "season",
    SUM("away_team_goal") AS "goals"
  FROM "EU_SOCCER"."EU_SOCCER"."MATCH"
  GROUP BY "away_team_api_id", "season"
),
total_goals_per_team_season AS (
  -- Combine home and away goals for each team in each season
  SELECT 
    "team_api_id",
    "season",
    SUM("goals") AS "total_goals"
  FROM team_goals_by_season
  GROUP BY "team_api_id", "season"
),
max_goals_per_team AS (
  -- Find the maximum goals for each team across all seasons
  SELECT 
    "team_api_id",
    MAX("total_goals") AS "max_season_goals"
  FROM total_goals_per_team_season
  GROUP BY "team_api_id"
)
-- Calculate the median of the maximum season goals
SELECT 
  MEDIAN("max_season_goals") AS "median_of_highest_season_goals"
FROM max_goals_per_team;