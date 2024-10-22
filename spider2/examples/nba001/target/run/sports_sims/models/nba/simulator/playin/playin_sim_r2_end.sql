
  
    
    

    create  table
      "nba"."main"."playin_sim_r2_end__dbt_tmp"
  
    as (
      select
    p1.scenario_id,
    p1.conf,
    p1.winning_team,
    p1.conf || '-7' as seed,
    p1.winning_team_elo_rating
from "nba"."main"."playin_sim_r1_end" p1
where p1.result = 'winner advance'
union all
select
    p2.scenario_id,
    p2.conf as conf,
    p2.winning_team,
    p2.conf || '-8' as seed,
    case
        when p2.winning_team = p2.home_team
        then p2.home_team_elo_rating
        else p2.visiting_team_elo_rating
    end as elo_rating
from "nba"."main"."playin_sim_r2" p2
    );
  
  