select
    r.scenario_id,
    s.game_id,
    ev.conf as conf,
    ev.winning_team as visiting_team,
    ev.elo_rating as visiting_team_elo_rating,
    eh.winning_team as home_team,
    eh.elo_rating as home_team_elo_rating,
    ( 1 - (1 / (10 ^ (-( EV.elo_rating - EH.elo_rating - 100)::real/400)+1))) * 10000
    as home_team_win_probability,
    r.rand_result,
    case
        when
            ( 1 - (1 / (10 ^ (-( EV.elo_rating - EH.elo_rating - 100)::real/400)+1))) * 10000
            >= r.rand_result
        then eh.winning_team
        else ev.winning_team
    end as winning_team
from "nba"."main"."nba_schedules" s
left join "nba"."main"."nba_random_num_gen" r on r.game_id = s.game_id
left join
    "nba"."main"."reg_season_end" eh
    on s.home_team = eh.seed
    and r.scenario_id = eh.scenario_id
left join
    "nba"."main"."reg_season_end" ev
    on s.visiting_team = ev.seed
    and r.scenario_id = ev.scenario_id
where s.type = 'playin_r1'