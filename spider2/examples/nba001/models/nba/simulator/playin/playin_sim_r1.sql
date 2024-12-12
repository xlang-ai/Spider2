select
    r.scenario_id,
    s.game_id,
    ev.conf as conf,
    ev.winning_team as visiting_team,
    ev.elo_rating as visiting_team_elo_rating,
    eh.winning_team as home_team,
    eh.elo_rating as home_team_elo_rating,
    {{ elo_calc("EH.elo_rating", "EV.elo_rating", var("nba_elo_offset")) }}
    as home_team_win_probability,
    r.rand_result,
    case
        when
            {{ elo_calc("EH.elo_rating", "EV.elo_rating", var("nba_elo_offset")) }}
            >= r.rand_result
        then eh.winning_team
        else ev.winning_team
    end as winning_team
from {{ ref("nba_schedules") }} s
left join {{ ref("nba_random_num_gen") }} r on r.game_id = s.game_id
left join
    {{ ref("reg_season_end") }} eh
    on s.home_team = eh.seed
    and r.scenario_id = eh.scenario_id
left join
    {{ ref("reg_season_end") }} ev
    on s.visiting_team = ev.seed
    and r.scenario_id = ev.scenario_id
where s.type = 'playin_r1'
