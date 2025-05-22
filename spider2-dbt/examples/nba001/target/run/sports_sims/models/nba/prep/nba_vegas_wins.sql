
  
    
    

    create  table
      "nba"."main"."nba_vegas_wins__dbt_tmp"
  
    as (
      select team, win_total::double as win_total from "nba"."main"."nba_ratings" group by all
    );
  
  