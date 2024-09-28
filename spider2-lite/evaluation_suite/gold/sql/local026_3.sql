-- Step 1: Calculate players' total runs in each match
WITH player_runs AS (
    SELECT 
        bbb.striker AS player_id, 
        bbb.match_id, 
        SUM(bsc.runs_scored) AS total_runs 
    FROM 
        ball_by_ball AS bbb
    JOIN 
        batsman_scored AS bsc
    ON 
        bbb.match_id = bsc.match_id 
        AND bbb.over_id = bsc.over_id 
        AND bbb.ball_id = bsc.ball_id 
        AND bbb.innings_no = bsc.innings_no
    GROUP BY 
        bbb.striker, bbb.match_id
    HAVING 
        SUM(bsc.runs_scored) >= 100
),

-- Step 2: Identify losing teams for each match
losing_teams AS (
    SELECT 
        match_id, 
        CASE 
            WHEN match_winner = team_1 THEN team_2 
            ELSE team_1 
        END AS loser 
    FROM 
        match
),

-- Step 3: Combine the above results to get players who scored 100 or more runs in losing teams
players_in_losing_teams AS (
    SELECT 
        pr.player_id, 
        pr.match_id 
    FROM 
        player_runs AS pr
    JOIN 
        losing_teams AS lt
    ON 
        pr.match_id = lt.match_id
    JOIN 
        player_match AS pm
    ON 
        pr.player_id = pm.player_id 
        AND pr.match_id = pm.match_id 
        AND lt.loser = pm.team_id
)

-- Step 4: Select distinct player names from the player table
SELECT DISTINCT 
    p.player_name 
FROM 
    player AS p
JOIN 
    players_in_losing_teams AS plt
ON 
    p.player_id = plt.player_id
ORDER BY 
    p.player_name;