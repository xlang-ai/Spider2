WITH wickets_table AS (
    SELECT 
        bowler,
        pl.player_name AS player_name,
        COUNT(kind_out) AS wickets 
    FROM wicket_taken wkt
    JOIN ball_by_ball byb ON byb.match_id = wkt.match_id 
        AND byb.over_id = wkt.over_id 
        AND byb.ball_id = wkt.ball_id 
        AND byb.innings_no = wkt.innings_no
    JOIN player pl ON byb.bowler = pl.player_id
    GROUP BY player_name
),
balls_table AS (
    SELECT 
        bowler,
        COUNT(ball_id) AS Balls_Bowled 
    FROM ball_by_ball
    GROUP BY bowler
),
economy_table AS (
    SELECT
        a.bowler,
        COUNT(DISTINCT a.match_id) AS Innings_Bowled,
        a.bowler_name,
        a.role,
        SUM(a.runs) AS runs_given
    FROM (
        SELECT
            byb.match_id AS match_id,
            byb.over_id AS over_id,
            byb.ball_id AS ball_id,
            byb.innings_no AS innings_no,
            byb.team_batting AS team_batting,
            striker,
            non_striker,
            bowler,
            pm.role,
            batting_hand AS batting_hand,
            pl.player_name AS bowler_name,
            runs_scored AS runs 
        FROM ball_by_ball byb
        JOIN batsman_scored bsco ON byb.ball_id = bsco.ball_id 
            AND byb.match_id = bsco.match_id 
            AND byb.over_id = bsco.over_id 
            AND byb.innings_no = bsco.innings_no
        JOIN player_match pm ON bsco.match_id = pm.match_id
        JOIN player pl ON byb.bowler = pl.player_id
        GROUP BY striker, byb.match_id, byb.over_id, byb.ball_id, bsco.innings_no
        ORDER BY bsco.innings_no ASC
    ) a
    GROUP BY a.bowler_name
    ORDER BY a.bowler
),
best_bowling_table AS (
    SELECT
        a.match_id,
        a.bowler,
        MAX(a.wickets),
        a.runs_given,
        MAX(a.wickets) || '-' || a.runs_given AS Best_Bowling_figure
    FROM (
        SELECT
            wt.match_id,
            wt.bowler,
            wt.wickets,
            rt.runs_given
        FROM (
            SELECT 
                byb.match_id, 
                bowler, 
                COUNT(byb.ball_id) AS wickets 
            FROM ball_by_ball byb
            JOIN wicket_taken wkt ON byb.match_id = wkt.match_id 
                AND byb.over_id = wkt.over_id 
                AND byb.ball_id = wkt.ball_id 
                AND byb.innings_no = wkt.innings_no
            GROUP BY byb.match_id, bowler
        ) wt
        JOIN (
            SELECT 
                byb.match_id, 
                bowler, 
                SUM(runs_scored) AS runs_given 
            FROM ball_by_ball byb
            JOIN batsman_scored bs ON byb.match_id = bs.match_id 
                AND byb.over_id = bs.over_id 
                AND byb.ball_id = bs.ball_id 
                AND byb.innings_no = bs.innings_no
            GROUP BY bs.match_id, bowler
        ) rt ON rt.match_id = wt.match_id
    ) a
    GROUP BY a.bowler
    ORDER BY a.wickets DESC
)
SELECT
    c.bowler,
    c.player_name,
    c.wickets,
    c.economy_rate,
    c.bowler_strike_rate,
    best_bowling_table.Best_Bowling_figure
FROM (
    SELECT 
        a.bowler,
        a.player_name,
        a.wickets,
        balls_table.Balls_Bowled AS Balls_bowled,
        economy_table.runs_given AS runs_given,
        6 * (1.0 * economy_table.runs_given / balls_table.Balls_Bowled) AS economy_rate,
        1.0 * balls_table.Balls_Bowled / a.wickets AS bowler_strike_rate
    FROM wickets_table a
    JOIN balls_table ON a.bowler = balls_table.bowler
    JOIN economy_table ON a.bowler = economy_table.bowler
    ORDER BY a.wickets DESC
) c
JOIN best_bowling_table ON c.bowler = best_bowling_table.bowler
ORDER BY wickets DESC
LIMIT 5;