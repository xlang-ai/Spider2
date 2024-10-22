select
    r.scenario_id,
    s.*,
    {{
        elo_calc(
            "S.home_team_elo_rating",
            "S.visiting_team_elo_rating",
            var("nba_elo_offset"),
        )
    }} as home_team_win_probability,
    r.rand_result,
    case
        when lr.include_actuals = true
        then lr.winning_team_short
        when
            {{
                elo_calc(
                    "S.home_team_elo_rating",
                    "S.visiting_team_elo_rating",
                    var("nba_elo_offset"),
                )
            }} >= r.rand_result
        then s.home_team
        else s.visiting_team
    end as winning_team,
    coalesce(lr.include_actuals, false) as include_actuals,
    lr.home_team_score as actual_home_team_score,
    lr.visiting_team_score as actual_visiting_team_score,
    lr.margin as actual_margin
from {{ ref("nba_schedules") }} s
left join {{ ref("nba_random_num_gen") }} r on r.game_id = s.game_id
left join {{ ref("nba_latest_results") }} lr on lr.game_id = s.game_id
where s.type in ('reg_season', 'tournament', 'knockout')
