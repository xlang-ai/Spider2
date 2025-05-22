with
    cte_team_scores as (
        from "nba"."main"."nba_results_by_team"
        select team, avg(score) as pts
        group by all
    ),
    cte_interim_calcs as (
        select
            game_id,
            date,
            home_team,
            home_team_elo_rating,
            visiting_team,
            visiting_team_elo_rating,
            home_team_win_probability,
            winning_team,
            include_actuals,
            count(*) as occurances,
            CASE WHEN home_team_win_probability/10000 >= 0.5 
        THEN '-' || ROUND( home_team_win_probability/10000 / ( 1.0 - home_team_win_probability/10000 ) * 100 )::int
        ELSE '+' || ((( 1.0 - home_team_win_probability/10000 ) / (home_team_win_probability/10000::real ) * 100)::int)
    END as american_odds,
            type,
            actual_home_team_score,
            actual_visiting_team_score,
            case
                when actual_home_team_score > actual_visiting_team_score
                then actual_margin * -1
                else actual_margin
            end as actual_margin,
            (h.pts + v.pts) / 2.0 as avg_score,
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
        from "nba"."main"."reg_season_simulator" s
        left join cte_team_scores h on h.team = s.home_team
        left join cte_team_scores v on v.team = s.visiting_team
        group by all
    ),
    cte_final as (
        select
            *,
            round(avg_score - (implied_line / 2.0), 0) as home_score,
            round(avg_score + (implied_line / 2.0), 0) as visiting_score
        from cte_interim_calcs
    )
select
    *,
    home_team
    || ' '
    || home_score::int
    || ' - '
    || visiting_score::int
    || ' '
    || visiting_team as predicted_score
from cte_final