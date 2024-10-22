
  
    
    

    create  table
      "nba"."main"."nba_elo_history__dbt_tmp"
  
    as (
      

select a.*
from 'data/nba/nba_elo.csv' a
union all
select
    l.game_date as date,
    2024 as season,
    null as nuetral,
    'r' as playoff,
    l.hmtm as team1,
    l.vstm as team2,
    r.home_team_elo_rating as elo1_pre,
    r.visiting_team_elo_rating as elo2_pre,
    null as elo_prob1,
    null as elo_prob2,
    case
        when l.home_team_score > l.visiting_team_score
        then r.home_team_elo_rating - r.elo_change
        else r.home_team_elo_rating + r.elo_change
    end as elo1_post,
    case
        when l.home_team_score > l.visiting_team_score
        then r.visiting_team_elo_rating + r.elo_change
        else r.visiting_team_elo_rating - r.elo_change
    end as elo2_post,
    l.home_team_score as score1,
    l.visiting_team_score as score2
from "nba"."main"."nba_elo_rollforward" r
left join "nba"."main"."nba_results_log" l on r.game_id = l.game_id
    );
  
  