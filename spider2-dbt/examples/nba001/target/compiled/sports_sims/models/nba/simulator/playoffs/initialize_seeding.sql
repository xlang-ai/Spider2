with
    cte_teams as (
        select scenario_id, conf, winning_team, seed, elo_rating
        from "nba"."main"."reg_season_end"
        where season_rank < 7
        union all
        select *
        from "nba"."main"."playin_sim_r2_end"
    )

select t.*, 0 as sim_start_game_id
from cte_teams t