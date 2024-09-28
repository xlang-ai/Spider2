WITH player_runs AS (
    SELECT 
        b.striker AS player_id, 
        b.match_id, 
        SUM(bs.runs_scored) AS total_runs 
    FROM 
        ball_by_ball b
        JOIN batsman_scored bs
        ON b.match_id = bs.match_id 
        AND b.over_id = bs.over_id 
        AND b.ball_id = bs.ball_id 
        AND b.innings_no = bs.innings_no
    GROUP BY 
        b.striker, b.match_id
), 
player_averages AS (
    SELECT 
        player_id, 
        AVG(total_runs) AS batting_avg 
    FROM 
        player_runs 
    GROUP BY 
        player_id
), 
country_averages AS (
    SELECT 
        p.country_name, 
        AVG(pa.batting_avg) AS country_batting_avg 
    FROM 
        player_averages pa
        JOIN player p
        ON pa.player_id = p.player_id
    GROUP BY 
        p.country_name
) 
SELECT 
    country_name, country_batting_avg
FROM 
    country_averages 
ORDER BY 
    country_batting_avg DESC
LIMIT 5;