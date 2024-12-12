
  
    
    

    create  table
      "nba"."main"."nba_xf_series_to_seed__dbt_tmp"
  
    as (
      select series_id, seed from "nba"."main"."nba_raw_xf_series_to_seed"
    );
  
  