
  
    
    

    create  table
      "nba"."main"."nba_schedules__dbt_tmp"
  
    as (
      select *
from "nba"."main"."nba_reg_season_schedule"
union all
select *
from "nba"."main"."nba_post_season_schedule"
    );
  
  