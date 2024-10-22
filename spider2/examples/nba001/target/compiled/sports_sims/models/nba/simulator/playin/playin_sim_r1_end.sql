with
    cte_playin_details as (
        select
            s.scenario_id,
            s.game_id,
            s.winning_team,
            case
                when s.winning_team = s.home_team
                then s.home_team_elo_rating
                else s.visiting_team_elo_rating
            end as winning_team_elo_rating,
            s.conf as conf,
            case
                when s.winning_team = s.home_team then s.visiting_team else s.home_team
            end as losing_team,
            case
                when s.winning_team = s.home_team
                then s.visiting_team_elo_rating
                else s.home_team_elo_rating
            end as losing_team_elo_rating,
            case
                when s.game_id in (1231, 1234)
                then 'winner advance'
                when s.game_id in (1232, 1235)
                then 'loser eliminated'
            end as result
        from "nba"."main"."playin_sim_r1" s
    )

select
    *,
    case
        when game_id in (1231, 1234)
        then losing_team
        when game_id in (1232, 1235)
        then winning_team
    end as remaining_team
from cte_playin_details