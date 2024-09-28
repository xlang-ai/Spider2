SELECT 
    s.striker,
    s.striker_name,
    s.role,
    s.batting_hand,
    bowling_style_table.bowling_skill,
    s.runs,
    s.matches,
    s.dismissals,
    1.0 * s.runs / s.dismissals AS batt_avg,
    s.Highest_score,
    s.thirties, 
    s.fifties,
    s.hundreds,
    s.balls_faced_career,
    s.strike_rate,
    s.wickets_taken,
    s.economy_rate,
    s.best_bowling_figure
FROM (
    SELECT
        f.striker,
        f.striker_name,
        f.role,
        f.batting_hand,
        f.runs,
        f.matches,
        f.dismissals,
        1.0 * f.runs / f.dismissals AS batt_avg,
        f.Highest_score,
        f.thirties, 
        f.fifties,
        f.hundreds,
        f.balls_faced_career,
        f.strike_rate,
        f.wickets_taken,
        bowler_table.economy_rate AS economy_rate,
        bowler_table.bowler_strike_rate AS strike_rate,
        bowler_table.best_bowling_figure AS best_bowling_figure
    FROM (
        SELECT 
            g.striker,
            g.striker_name,
            g.role,
            g.batting_hand,
            g.runs,
            g.matches,
            g.dismissals,
            1.0 * g.runs / g.dismissals AS batt_avg,
            g.Highest_score,
            g.thirties, 
            g.fifties,
            g.hundreds,
            g.balls_faced_career,
            g.strike_rate,
            bowlers_table.wickets AS wickets_taken
        FROM (
            SELECT
                f.striker,
                f.striker_name,
                f.role,
                f.batting_hand,
                f.runs,
                f.matches,
                dissmissals_table.dismissals AS dismissals,
                1.0 * f.runs / dissmissals_table.dismissals AS batt_avg,
                f.Highest_score,
                f.thirties, 
                f.fifties,
                f.hundreds,
                f.balls_faced_career,
                f.strike_rate
            FROM (
                SELECT 
                    e.striker,
                    e.striker_name,
                    e.role,
                    e.batting_hand,
                    e.runs,
                    e.matches,
                    1.0 * e.runs / e.matches AS batt_avg,
                    e.Highest_score,
                    e.thirties, 
                    e.fifties,
                    e.hundreds,
                    SUM(ball_face_by_batsman_per_match) AS balls_faced_career,
                    100 * (1.0 * e.runs / SUM(ball_face_by_batsman_per_match)) AS strike_rate
                FROM (
                    SELECT
                        d.striker,
                        d.striker_name,
                        d.role,
                        d.batting_hand,
                        d.runs,
                        d.matches,
                        100.0 * d.runs / d.matches AS batt_avg,
                        MAX(d.max_individual_score_per_match) AS Highest_score,
                        d.thirties, 
                        d.fifties,
                        d.hundreds
                    FROM (
                        SELECT 
                            c.striker,
                            c.striker_name,
                            c.role,
                            c.batting_hand,
                            c.runs,
                            c.matches,
                            c.max_individual_score_per_match,
                            fifties_hundreds_table.thirties, 
                            fifties_hundreds_table.fifties,
                            fifties_hundreds_table.hundreds
                        FROM (
                            SELECT 
                                runs_table.striker,
                                runs_table.striker_name,
                                runs_table.matches,
                                runs_table.role,
                                runs_table.batting_hand,
                                runs_table.runs,
                                highest_score.runs AS max_individual_score_per_match
                            FROM (
                                SELECT 
                                    * 
                                FROM (
                                    SELECT
                                        a.striker,
                                        COUNT(DISTINCT a.match_id) AS Matches,
                                        a.striker_name,
                                        a.role,
                                        a.batting_hand,
                                        SUM(a.runs) AS runs
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
                                            role,
                                            batting_hand AS batting_hand,
                                            pl.player_name AS striker_name,
                                            runs_scored AS runs
                                        FROM ball_by_ball byb
                                        JOIN batsman_scored bsco ON byb.ball_id = bsco.ball_id 
                                            AND byb.match_id = bsco.match_id 
                                            AND byb.over_id = bsco.over_id 
                                            AND byb.innings_no = bsco.innings_no
                                        JOIN player_match pm ON bsco.match_id = pm.match_id
                                        JOIN player pl ON byb.striker = pl.player_id
                                        GROUP BY
                                            striker,
                                            byb.match_id,
                                            byb.over_id,
                                            byb.ball_id
                                        ORDER BY bsco.innings_no ASC
                                    ) a
                                    GROUP BY a.striker_name
                                    ORDER BY a.striker
                                ) b
                                GROUP BY b.striker_name, b.striker, b.matches
                                ORDER BY b.runs DESC
                            ) runs_table
                            JOIN (
                                SELECT 
                                    * 
                                FROM (
                                    SELECT 
                                        striker,
                                        bs.match_id,
                                        player_name,
                                        byb.innings_no, 
                                        SUM(runs_scored) AS runs 
                                    FROM ball_by_ball byb
                                    JOIN batsman_scored bs ON byb.match_id = bs.match_id 
                                        AND byb.over_id = bs.over_id 
                                        AND byb.ball_id = bs.ball_id 
                                        AND byb.innings_no = bs.innings_no
                                    JOIN player pl ON byb.striker = pl.player_id
                                    GROUP BY 
                                        bs.match_id,
                                        player_name
                                    ORDER BY byb.innings_no
                                ) a
                                ORDER BY a.runs DESC
                            ) highest_score ON runs_table.striker = highest_score.striker 
                                AND runs_table.striker = highest_score.striker
                        ) c
                        JOIN (
                            SELECT 
                                b.striker,
                                b.player_name,
                                SUM(b.thirties) AS thirties,
                                SUM(b.fifties) AS fifties,
                                SUM(b.hundreds) AS hundreds 
                            FROM (
                                SELECT *,
                                    (CASE WHEN a.runs >= 30 THEN 1 ELSE 0 END) AS thirties,
                                    (CASE WHEN a.runs >= 50 THEN 1 ELSE 0 END) AS fifties,
                                    (CASE WHEN a.runs >= 100 THEN 1 ELSE 0 END) AS hundreds 
                                FROM (
                                    SELECT 
                                        striker,
                                        bs.match_id,
                                        player_name,
                                        byb.innings_no, 
                                        SUM(runs_scored) AS runs 
                                    FROM ball_by_ball byb
                                    JOIN batsman_scored bs ON byb.match_id = bs.match_id 
                                        AND byb.over_id = bs.over_id 
                                        AND byb.ball_id = bs.ball_id 
                                        AND byb.innings_no = bs.innings_no
                                    JOIN player pl ON byb.striker = pl.player_id
                                    GROUP BY 
                                        bs.match_id,
                                        player_name
                                    ORDER BY byb.innings_no
                                ) a
                                ORDER BY a.runs DESC
                            ) b
                            GROUP BY b.player_name
                            ORDER BY b.striker
                        ) fifties_hundreds_table ON c.striker = fifties_hundreds_table.striker
                    ) d
                    GROUP BY d.striker_name
                    ORDER BY d.matches DESC
                ) e
                JOIN (
                    SELECT 
                        match_id,
                        striker,
                        COUNT(ball_id) AS ball_face_by_batsman_per_match 
                    FROM ball_by_ball
                    GROUP BY striker, match_id
                ) ball_faced_table ON e.striker = ball_faced_table.striker
                GROUP BY e.striker
            ) f
            JOIN (
                SELECT 
                    * 
                FROM (
                    SELECT 
                        player_out,
                        COUNT(kind_out) AS dismissals 
                    FROM wicket_taken wkt
                    GROUP BY player_out
                ) a
            ) dissmissals_table ON f.striker = dissmissals_table.player_out
            GROUP BY f.striker
        ) g
        JOIN (
            SELECT 
                * 
            FROM (
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
            ) a
            ORDER BY a.wickets DESC
        ) bowlers_table ON g.striker = bowlers_table.bowler
        ORDER BY g.striker
    ) f
    JOIN (
        SELECT
            c.bowler,
            c.player_name,
            c.wickets,
            c.economy_rate,
            c.bowler_strike_rate,
            best_bowling_table.best_bowling_figure
        FROM (
            SELECT 
                a.bowler,
                a.player_name,
                a.wickets,
                balls_table.balls_bowled AS Balls_bowled,
                economy_table.runs_given AS runs_given,
                6 * (1.0 * economy_table.runs_given / balls_table.balls_bowled) AS economy_rate,
                1.0 * balls_table.balls_bowled / a.wickets AS bowler_strike_rate
            FROM (
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
            ) a
            JOIN (
                SELECT 
                    bowler,
                    COUNT(ball_id) AS Balls_Bowled 
                FROM ball_by_ball
                GROUP BY bowler
            ) balls_table ON a.bowler = balls_table.bowler
            JOIN (
                SELECT 
                    * 
                FROM (
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
                            role,
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
                        GROUP BY
                            striker,
                            byb.match_id,
                            byb.over_id,
                            byb.ball_id,
                            bsco.innings_no
                        ORDER BY bsco.innings_no ASC
                    ) a
                    GROUP BY a.bowler_name
                    ORDER BY a.bowler
                ) b
                ORDER BY b.runs_given DESC
            ) economy_table ON a.bowler = economy_table.bowler
            ORDER BY a.wickets DESC
        ) c
        JOIN (
            SELECT
                a.match_id,
                a.bowler,
                MAX(a.wickets) AS max_wickets,
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
        ) best_bowling_table ON c.bowler = best_bowling_table.bowler
    ) bowler_table ON f.striker_name = bowler_table.player_name
) s
JOIN (
    SELECT 
        player_name,
        bowling_skill 
    FROM player p
) bowling_style_table ON s.striker_name = bowling_style_table.player_name
