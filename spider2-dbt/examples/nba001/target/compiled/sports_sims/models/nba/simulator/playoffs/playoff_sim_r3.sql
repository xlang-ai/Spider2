with
    cte_playoff_sim as (
-- depends-on: "nba"."main"."nba_random_num_gen"

    WITH cte_step_1 AS (
        SELECT
        R.scenario_id,
        S.game_id,
        S.series_id,
        S.visiting_team AS visitor_key,
        S.home_team AS home_key,
        EV.winning_team AS visiting_team,
        EV.elo_rating AS visiting_team_elo_rating,
        EH.winning_team AS home_team,
        EH.elo_rating AS home_team_elo_rating,
        ( 1 - (1 / (10 ^ (-( EV.elo_rating - EH.elo_rating - 100)::real/400)+1))) * 10000 as home_team_win_probability,
        R.rand_result,
        CASE
            WHEN ( 1 - (1 / (10 ^ (-( EV.elo_rating - EH.elo_rating - 100)::real/400)+1))) * 10000 >= R.rand_result THEN EH.winning_team
            ELSE EV.winning_team
        END AS winning_team 
        FROM "nba"."main"."nba_schedules" S
        LEFT JOIN "nba"."main"."nba_random_num_gen" R ON R.game_id = S.game_id
        LEFT JOIN  "nba"."main"."playoff_sim_r2" EH ON S.home_team = EH.seed AND R.scenario_id = EH.scenario_id
        LEFT JOIN  "nba"."main"."playoff_sim_r2" EV ON S.visiting_team = EV.seed AND R.scenario_id = EV.scenario_id
        WHERE S.type =  'playoffs_r3'
    ),
    cte_step_2 AS (
        SELECT step1.*,
            ROW_NUMBER() OVER (PARTITION BY scenario_id, series_id, winning_team  ORDER BY scenario_id, series_id, game_id ) AS series_result
        FROM cte_step_1 step1
    ),
    cte_final_game AS (
        SELECT scenario_id,
            series_id,
            game_id
        FROM cte_step_2
        WHERE series_result = 4
    )
    SELECT step2.* 
    FROM cte_step_2 step2
        INNER JOIN cte_final_game F ON F.scenario_id = step2.scenario_id 
            AND f.series_id = step2.series_id AND step2.game_id <= f.game_id
    ORDER BY step2.scenario_id, 
        step2.series_id, 
        step2.game_id)

    SELECT
    E.scenario_id,
    E.series_id,
    E.game_id,
    E.winning_team,
    CASE WHEN E.winning_team = E.home_team THEN E.home_team_elo_rating
        ELSE E.visiting_team_elo_rating
    END AS elo_rating,
    XF.seed,
    0 AS sim_start_game_id
FROM cte_playoff_sim E
LEFT JOIN "nba"."main"."nba_xf_series_to_seed" XF ON XF.series_id = E.series_id
WHERE E.series_result = 4