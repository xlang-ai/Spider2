
  
    
    

    create  table
      "nba"."main"."nba_results_log__dbt_tmp"
  
    as (
      with
    cte_avg_elo as (
        select avg(elo_rating) as elo_rating from "nba"."main"."nba_latest_elo"
    )
select
    rl.*,
    a.elo_rating as avg,
    case
        when rl.visiting_team_elo_rating > rl.home_team_elo_rating
        then rl.visiting_team
        else rl.home_team
    end as favored_team,
    case
        when rl.visiting_team_elo_rating > a.elo_rating then 1 else 0
    end as visiting_team_above_avg,
    case
        when rl.home_team_elo_rating > a.elo_rating then 1 else 0
    end as home_team_above_avg,
    case
        when rl.winning_team = rl.home_team then rl.visiting_team else rl.home_team
    end as losing_team,
    lr.game_date,
    lr.home_team_score,
    lr.visiting_team_score,
    h.team as hmtm,
    v.team as vstm,
    s.type
from "nba"."main"."nba_elo_rollforward" rl
left join cte_avg_elo a on 1 = 1
left join "nba"."main"."nba_latest_results" lr on lr.game_id = rl.game_id
left join "nba"."main"."nba_teams" h on h.team_long = rl.home_team
left join "nba"."main"."nba_teams" v on v.team_long = rl.visiting_team
left join "nba"."main"."nba_schedules" s on s.game_id = rl.game_id
    );
  
  