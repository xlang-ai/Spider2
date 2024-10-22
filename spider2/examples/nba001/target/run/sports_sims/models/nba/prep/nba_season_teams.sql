
  
    
    

    create  table
      "nba"."main"."nba_season_teams__dbt_tmp"
  
    as (
      select c.*
from
    (
        select a.season, a.team1 as team
        from "nba"."main"."nba_elo_history" a
        union all
        select b.season, b.team2
        from "nba"."main"."nba_elo_history" b
    ) as c
group by all
order by c.team
    );
  
  