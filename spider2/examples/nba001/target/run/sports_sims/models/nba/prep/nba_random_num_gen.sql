
  
    
    

    create  table
      "nba"."main"."nba_random_num_gen__dbt_tmp"
  
    as (
      

with
    cte_scenario_gen as (
        select i.generate_series as scenario_id
        from generate_series(1, 10000) as i
    )
select
    i.scenario_id,
    s.game_id,
    (random() * 10000)::smallint as rand_result,
    0 as sim_start_game_id
from cte_scenario_gen as i
cross join
    "nba"."main"."nba_schedules" as s
    -- LEFT JOIN "nba"."main"."nba_latest_results" AS R ON R.game_id = S.game_id
    -- WHERE R.game_id IS NULL OR (R.game_id IS NOT NULL AND i.scenario_id = 1)
    );
  
  