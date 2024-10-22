with
    cte_inner as (
        select
            s.id as game_id,
            s."date" as game_date,
            s.hometm as home_team,
            case
                when s.hometm = r.winner then r.winner_pts else r.loser_pts
            end as home_team_score,
            s.vistm as visiting_team,
            case
                when s.vistm = r.winner then r.winner_pts else r.loser_pts
            end as visiting_team_score,
            r.winner as winning_team,
            r.loser as losing_team,
            True as include_actuals
        from "nba"."main"."nba_raw_schedule" s
        left join
            "nba"."main"."nba_raw_results" r
            on r."date" = s."date"
            and (s.vistm = r.winner or s.vistm = r.loser)
        where home_team_score is not null
        group by all
    ),
    cte_outer as (
        select
            i.*,
            case
                when visiting_team_score > home_team_score
                then 1
                when visiting_team_score = home_team_score
                then 0.5
                else 0
            end as game_result,
            abs(visiting_team_score - home_team_score) as margin,
            w.team as winning_team_short,
            l.team as losing_team_short
        from cte_inner i
        left join "nba"."main"."nba_teams" w on w.team_long = i.winning_team
        left join "nba"."main"."nba_teams" l on l.team_long = i.losing_team
    )
select
    *
from cte_outer