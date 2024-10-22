
  
    
    

    create  table
      "nba"."main"."nba_reg_season_schedule__dbt_tmp"
  
    as (
      select
    s.id as game_id,
    s.date as date,
    case
        when s.notes = 'In-Season Tournament'
        then 'tournament'
        when s.notes = 'Knockout Rounds'
        then 'knockout'
        else 'reg_season'
    end as type,
    0 as series_id,
    v.conf as visiting_conf,
    v.team as visiting_team,
    coalesce(r.visiting_team_elo_rating, v.elo_rating::int) as visiting_team_elo_rating,
    h.conf as home_conf,
    h.team as home_team,
    coalesce(r.home_team_elo_rating, h.elo_rating::int) as home_team_elo_rating
from "nba"."main"."nba_raw_schedule" as s
left join "nba"."main"."nba_ratings" v on v.team_long = s.vistm
left join "nba"."main"."nba_ratings" h on h.team_long = s.hometm
left join "nba"."main"."nba_elo_rollforward" r on r.game_id = s.id
where s.type = 'reg_season'
group by all
    );
  
  