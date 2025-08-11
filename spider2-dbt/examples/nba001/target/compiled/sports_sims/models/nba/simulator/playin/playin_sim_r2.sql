select
    r.scenario_id,
    s.game_id,
    s.home_team[7:] as home_team_id,
    s.visiting_team[8:] as visiting_team_id,
    ev.conf as conf,
    ev.remaining_team as visiting_team,
    ev.winning_team_elo_rating as visiting_team_elo_rating,
    eh.remaining_team as home_team,
    eh.losing_team_elo_rating as home_team_elo_rating,
    ( 1 - (1 / (10 ^ (-( EV.winning_team_elo_rating - EH.losing_team_elo_rating - 100)::real/400)+1))) * 10000 as home_team_win_probability,
    r.rand_result,
    case
        when
            ( 1 - (1 / (10 ^ (-( EV.winning_team_elo_rating - EH.losing_team_elo_rating - 100)::real/400)+1))) * 10000 >= r.rand_result
        then eh.remaining_team
        else ev.remaining_team
    end as winning_team
from "nba"."main"."nba_schedules" s
left join "nba"."main"."nba_random_num_gen" r on r.game_id = s.game_id
left join
    "nba"."main"."playin_sim_r1_end" eh
    on r.scenario_id = eh.scenario_id
    and eh.game_id = s.home_team[7:]
left join
    "nba"."main"."playin_sim_r1_end" ev
    on r.scenario_id = ev.scenario_id
    and ev.game_id = s.visiting_team[8:]
where s.type = 'playin_r2'