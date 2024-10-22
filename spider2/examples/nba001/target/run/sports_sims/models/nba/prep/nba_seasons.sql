
  
    
    

    create  table
      "nba"."main"."nba_seasons__dbt_tmp"
  
    as (
      select a.season from "nba"."main"."nba_elo_history" a group by all order by a.season
    );
  
  