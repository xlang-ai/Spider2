WITH runs_scored AS (
    SELECT 
        bb.striker AS player_id,
        bb.match_id,
        bs.runs_scored AS runs
    FROM 
        ball_by_ball AS bb
    JOIN 
        batsman_scored AS bs ON bb.match_id = bs.match_id 
            AND bb.over_id = bs.over_id 
            AND bb.ball_id = bs.ball_id 
            AND bb.innings_no = bs.innings_no
    WHERE 
        bb.match_id IN (SELECT match_id FROM match WHERE season_id = 5)
),
total_runs AS (
    SELECT 
        player_id, 
        match_id, 
        SUM(runs) AS total_runs 
    FROM 
        runs_scored 
    GROUP BY 
        player_id, match_id
),
batting_averages AS (
    SELECT 
        player_id, 
        SUM(total_runs) AS runs, 
        COUNT(match_id) AS num_matches,
        ROUND(SUM(total_runs) / CAST(COUNT(match_id) AS FLOAT), 3) AS batting_avg
    FROM 
        total_runs 
    GROUP BY 
        player_id 
    ORDER BY 
        batting_avg DESC 
    LIMIT 5
)
SELECT 
    p.player_name,
    b.batting_avg
FROM 
    player AS p
JOIN 
    batting_averages AS b ON p.player_id = b.player_id
ORDER BY 
    b.batting_avg DESC;