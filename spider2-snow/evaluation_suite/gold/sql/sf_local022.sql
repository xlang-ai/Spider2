-- Step 1: Calculate players' total runs in each match
WITH PLAYER_RUNS AS (
    SELECT 
        BBB."striker" AS "player_id", 
        BBB."match_id", 
        SUM(CAST(BSC."runs_scored" AS DOUBLE)) AS "total_runs"
    FROM 
        IPL.IPL.BALL_BY_BALL AS BBB
    JOIN 
        IPL.IPL.BATSMAN_SCORED AS BSC
    ON 
        BBB."match_id" = BSC."match_id" 
        AND BBB."over_id" = BSC."over_id" 
        AND BBB."ball_id" = BSC."ball_id" 
        AND BBB."innings_no" = BSC."innings_no"
    GROUP BY 
        BBB."striker", BBB."match_id"
    HAVING 
        SUM(CAST(BSC."runs_scored" AS DOUBLE)) >= 100
),

-- Step 2: Identify losing teams for each match
LOSING_TEAMS AS (
    SELECT 
        "match_id", 
        CASE 
            WHEN "match_winner" = "team_1" THEN "team_2"
            ELSE "team_1" 
        END AS "loser" 
    FROM 
        IPL.IPL.MATCH
),

-- Step 3: Combine the above results to get players who scored 100 or more runs in losing teams
PLAYERS_IN_LOSING_TEAMS AS (
    SELECT 
        PR."player_id", 
        PR."match_id" 
    FROM 
        PLAYER_RUNS AS PR
    JOIN 
        LOSING_TEAMS AS LT
    ON 
        PR."match_id" = LT."match_id"
    JOIN 
        IPL.IPL.PLAYER_MATCH AS PM
    ON 
        PR."player_id" = PM."player_id" 
        AND PR."match_id" = PM."match_id" 
        AND LT."loser" = PM."team_id"
)

-- Step 4: Select distinct player names from the player table
SELECT DISTINCT 
    P."player_name" 
FROM 
    IPL.IPL.PLAYER AS P
JOIN 
    PLAYERS_IN_LOSING_TEAMS AS PLT
ON 
    P."player_id" = PLT."player_id"
ORDER BY 
    P."player_name";