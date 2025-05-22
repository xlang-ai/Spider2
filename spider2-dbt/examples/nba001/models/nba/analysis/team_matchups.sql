select
    home.team as home_team,
    home.elo_rating as home_elo_rating,
    away.team as away_team,
    away.elo_rating as away_elo_rating,
    {{ elo_calc("home_elo_rating", "away_elo_rating", var("nba_elo_offset")) }}
    as home_team_win_probability,
    home_elo_rating - away_elo_rating as elo_diff,
    elo_diff + 100 as elo_diff_hfa,
    home_team_win_probability / 10000 as home_win,
    {{ american_odds("home_team_win_probability/10000") }} as american_odds,
    round(
        case
            when home_team_win_probability / 10000 >= 0.50
            then round(-30.564 * home_team_win_probability / 10000 + 14.763, 1)
            else round(-30.564 * home_team_win_probability / 10000 + 15.801, 1)
        end
        * 2,
        0
    )
    / 2.0 as implied_line
from {{ ref("nba_ratings") }} home
join {{ ref("nba_ratings") }} away on 1 = 1
where home.team <> away.team
