{%- macro elo_calc(home_team, visiting_team, home_adv) -%}

   ( 1 - (1 / (10 ^ (-( {{visiting_team}} - {{home_team}} - {{home_adv}})::real/400)+1))) * 10000

{%- endmacro -%}

{%- macro elo_diff(home_team, visiting_team, result, home_adv)  -%}

   25.0 * (( {{result}} ) - (1 / (10 ^ ( - ({{visiting_team}} - {{home_team}} - {{home_adv}})::real / 400) + 1)))

{%- endmacro -%}

{% macro playoff_sim(round,seed_file) %}
-- depends-on: {{ ref( 'nba_random_num_gen' ) }}

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
        {{ elo_calc( 'EH.elo_rating', 'EV.elo_rating',var('nba_elo_offset') ) }} as home_team_win_probability,
        R.rand_result,
        CASE
            WHEN {{ elo_calc( 'EH.elo_rating', 'EV.elo_rating', var('nba_elo_offset') ) }} >= R.rand_result THEN EH.winning_team
            ELSE EV.winning_team
        END AS winning_team 
        FROM {{ ref( 'nba_schedules' ) }} S
        LEFT JOIN {{ ref( 'nba_random_num_gen' ) }} R ON R.game_id = S.game_id
        LEFT JOIN  {{ ref( seed_file ) }} EH ON S.home_team = EH.seed AND R.scenario_id = EH.scenario_id
        LEFT JOIN  {{ ref( seed_file ) }} EV ON S.visiting_team = EV.seed AND R.scenario_id = EV.scenario_id
        WHERE S.type =  '{{ round }}'
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
        step2.game_id

{%- endmacro -%}



{%- macro playoff_sim_end(precedent) -%}

SELECT
    E.scenario_id,
    E.series_id,
    E.game_id,
    E.winning_team,
    CASE WHEN E.winning_team = E.home_team THEN E.home_team_elo_rating
        ELSE E.visiting_team_elo_rating
    END AS elo_rating,
    XF.seed,
    {{ var( 'sim_start_game_id' ) }} AS sim_start_game_id
FROM {{ precedent }} E
LEFT JOIN {{ ref( 'nba_xf_series_to_seed' ) }} XF ON XF.series_id = E.series_id
WHERE E.series_result = 4

{%- endmacro -%}

{%- macro american_odds(value) -%}

    CASE WHEN {{ value }} >= 0.5 
        THEN '-' || ROUND( {{ value }} / ( 1.0 - {{ value }} ) * 100 )::int
        ELSE '+' || ((( 1.0 - {{ value }} ) / ({{ value }}::real ) * 100)::int)
    END 

{%- endmacro -%}