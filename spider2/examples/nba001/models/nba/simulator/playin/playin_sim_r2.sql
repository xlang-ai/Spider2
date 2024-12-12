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
    {{
        elo_calc(
            "EH.losing_team_elo_rating",
            "EV.winning_team_elo_rating",
            var("nba_elo_offset"),
        )
    }} as home_team_win_probability,
    r.rand_result,
    case
        when
            {{
                elo_calc(
                    "EH.losing_team_elo_rating",
                    "EV.winning_team_elo_rating",
                    var("nba_elo_offset"),
                )
            }} >= r.rand_result
        then eh.remaining_team
        else ev.remaining_team
    end as winning_team
from {{ ref("nba_schedules") }} s
left join {{ ref("nba_random_num_gen") }} r on r.game_id = s.game_id
left join
    {{ ref("playin_sim_r1_end") }} eh
    on r.scenario_id = eh.scenario_id
    and eh.game_id = s.home_team[7:]
left join
    {{ ref("playin_sim_r1_end") }} ev
    on r.scenario_id = ev.scenario_id
    and ev.game_id = s.visiting_team[8:]
where s.type = 'playin_r2'
