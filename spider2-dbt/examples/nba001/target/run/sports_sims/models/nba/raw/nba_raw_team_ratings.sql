
  
    
    

    create  table
      "nba"."main"."nba_raw_team_ratings__dbt_tmp"
  
    as (
      select * from 'data/nba/nba_team_ratings.csv'
    );
  
  