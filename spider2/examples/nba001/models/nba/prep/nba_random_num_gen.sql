{{ config(materialized="table") }}

with
    cte_scenario_gen as (
        select i.generate_series as scenario_id
        from generate_series(1, {{ var("scenarios") }}) as i
    )
select
    i.scenario_id,
    s.game_id,
    (random() * 10000)::smallint as rand_result,
    {{ var("sim_start_game_id") }} as sim_start_game_id
from cte_scenario_gen as i
cross join
    {{ ref("nba_schedules") }} as s
    -- LEFT JOIN {{ ref( 'nba_latest_results' )}} AS R ON R.game_id = S.game_id
    -- WHERE R.game_id IS NULL OR (R.game_id IS NOT NULL AND i.scenario_id = 1)
    
