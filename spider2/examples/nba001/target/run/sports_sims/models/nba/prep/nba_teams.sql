
  
    
    

    create  table
      "nba"."main"."nba_teams__dbt_tmp"
  
    as (
      select r.team_long, r.team, tournament_group, conf, alt_key
from "nba"."main"."nba_raw_team_ratings" r
    );
  
  