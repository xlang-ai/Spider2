WITH TABLE_1 AS (
    SELECT 
        MATCH."id",
        COUNTRY."name" AS country_name, 
        LEAGUE."name" AS league_name, 
        "season", 
        "stage", 
        "date",
        HT."team_long_name" AS home_team,
        AT."team_long_name" AS away_team,
        "home_team_goal", 
        "away_team_goal",
        CASE
            WHEN "home_team_goal" > "away_team_goal" THEN 'Win'
            WHEN "home_team_goal" < "away_team_goal" THEN 'Loss'
            ELSE 'Tie'
        END AS home_team_result, 
        CASE
            WHEN "away_team_goal" > "home_team_goal" THEN 'Win'
            WHEN "away_team_goal" < "home_team_goal" THEN 'Loss'
            ELSE 'Tie'
        END AS away_team_result
    FROM EU_SOCCER.EU_SOCCER.MATCH
    JOIN EU_SOCCER.EU_SOCCER.COUNTRY ON COUNTRY."id" = MATCH."country_id"
    JOIN EU_SOCCER.EU_SOCCER.LEAGUE ON LEAGUE."id" = MATCH."league_id"
    LEFT JOIN EU_SOCCER.EU_SOCCER.TEAM AS HT ON HT."team_api_id" = MATCH."home_team_api_id"
    LEFT JOIN EU_SOCCER.EU_SOCCER.TEAM AS AT ON AT."team_api_id" = MATCH."away_team_api_id"
),
HOME_TEAM AS (
    SELECT 
        "id",
        country_name, 
        league_name, 
        "season", 
        "stage", 
        "date",
        home_team AS team, 
        'Home' AS team_type,
        "home_team_goal" AS goals,
        home_team_result AS result
    FROM TABLE_1
),
AWAY_TEAM AS (
    SELECT 
        "id",
        country_name, 
        league_name, 
        "season", 
        "stage", 
        "date",
        away_team AS team, 
        'Away' AS team_type,
        "away_team_goal" AS goals,
        away_team_result AS result
    FROM TABLE_1
), 
TABLE_2 AS (
    SELECT * 
    FROM HOME_TEAM
    UNION ALL
    SELECT * 
    FROM AWAY_TEAM
),
TABLE_3 AS (
    SELECT *, 
        CASE 
            WHEN result = 'Win' THEN 3
            WHEN result = 'Tie' THEN 1
            ELSE 0
        END AS points
    FROM TABLE_2
), 
TABLE_4 AS (
    SELECT
        "season",
        team,
        league_name,
        country_name,
        SUM(points) AS total_points,
        RANK() OVER(PARTITION BY "season" ORDER BY SUM(points) DESC) AS season_rank
    FROM TABLE_3
    GROUP BY 
        "season", 
        team,
        league_name,
        country_name
    ORDER BY total_points DESC
)
SELECT * 
FROM TABLE_4 
WHERE season_rank = 1
ORDER BY total_points DESC;
