WITH goals_per_club AS (
    SELECT 
        "team",
        "season",
        SUM("goals") AS "total_goals"
    FROM (
        SELECT 
            "home_team_api_id" AS "team",
            "season",
            "home_team_goal" AS "goals"
        FROM 
            EU_SOCCER.EU_SOCCER."MATCH"
        UNION ALL
        SELECT 
            "away_team_api_id" AS "team",
            "season",
            "away_team_goal" AS "goals"
        FROM 
            EU_SOCCER.EU_SOCCER."MATCH"
    ) AS "goals_data"
    GROUP BY 
        "team", "season"
),
max_goals_per_team AS (
    SELECT 
        "team",
        MAX("total_goals") AS "max_goals"
    FROM 
        goals_per_club
    GROUP BY 
        "team"
),
ranked_goals AS (
    SELECT 
        "max_goals",
        ROW_NUMBER() OVER (ORDER BY "max_goals") AS "row_num",
        COUNT(*) OVER () AS "total_count"
    FROM 
        max_goals_per_team
)
SELECT 
    AVG("max_goals") AS "median_max_goals"
FROM 
    ranked_goals
WHERE 
    "row_num" IN (( "total_count" + 1) / 2, ( "total_count" + 2) / 2);
