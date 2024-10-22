
  
    
    

    create  table
      "nba"."main"."nba_raw_xf_series_to_seed__dbt_tmp"
  
    as (
      select * from 'data/nba/xf_series_to_seed.csv' group by all
    );
  
  