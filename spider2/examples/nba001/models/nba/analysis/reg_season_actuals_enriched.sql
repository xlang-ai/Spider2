{{ config(materialized="table") }}

with
    cte_wins as (
        select winning_team, count(*) as wins
        from {{ ref("nba_latest_results") }}
        group by all
    ),

    cte_losses as (
        select losing_team, count(*) as losses
        from {{ ref("nba_latest_results") }}
        group by all
    ),

    cte_favored_wins as (
        select lr.winning_team, count(*) as wins
        from {{ ref("nba_latest_results") }} lr
        inner join
            {{ ref("nba_results_log") }} r
            on r.game_id = lr.game_id
            and r.favored_team = lr.winning_team
        group by all
    ),

    cte_favored_losses as (
        select lr.losing_team, count(*) as losses
        from {{ ref("nba_latest_results") }} lr
        inner join
            {{ ref("nba_results_log") }} r
            on r.game_id = lr.game_id
            and r.favored_team = lr.losing_team
        group by all
    ),

    cte_avg_opponent_wins as (
        select lr.winning_team, count(*) as wins
        from {{ ref("nba_latest_results") }} lr
        inner join
            {{ ref("nba_results_log") }} r
            on r.game_id = lr.game_id
            and (
                (lr.winning_team = r.home_team and r.visiting_team_above_avg = 1)
                or (lr.winning_team = r.visiting_team and r.home_team_above_avg = 1)
            )
        group by all
    ),

    cte_avg_opponent_losses as (
        select lr.losing_team, count(*) as losses
        from {{ ref("nba_latest_results") }} lr
        inner join
            {{ ref("nba_results_log") }} r
            on r.game_id = lr.game_id
            and (
                (lr.losing_team = r.visiting_team and r.home_team_above_avg = 1)
                or (lr.losing_team = r.home_team and r.visiting_team_above_avg = 1)
            )
        group by all
    ),

    cte_home_wins as (
        select lr.home_team, count(*) as wins
        from {{ ref("nba_latest_results") }} lr
        where lr.home_team = lr.winning_team
        group by all
    ),

    cte_home_losses as (
        select lr.home_team, count(*) as losses
        from {{ ref("nba_latest_results") }} lr
        where lr.home_team = lr.losing_team
        group by all
    )

select
    t.team,
    coalesce(w.wins, 0) as wins,
    coalesce(l.losses, 0) as losses,
    coalesce(fw.wins, 0) as wins_as_favorite,
    coalesce(fl.losses, 0) as losses_as_favorite,
    coalesce(w.wins, 0) - coalesce(fw.wins, 0) as wins_as_underdog,
    coalesce(l.losses, 0) - coalesce(fl.losses, 0) as losses_as_underdog,
    coalesce(aw.wins, 0) as wins_vs_good_teams,
    coalesce(al.losses, 0) as losses_vs_good_teams,
    coalesce(w.wins, 0) - coalesce(aw.wins, 0) as wins_vs_bad_teams,
    coalesce(l.losses, 0) - coalesce(al.losses, 0) as losses_vs_bad_teams,
    coalesce(hw.wins, 0) as home_wins,
    coalesce(hl.losses, 0) as home_losses,
    coalesce(w.wins, 0) - coalesce(hw.wins, 0) as away_wins,
    coalesce(l.losses, 0) - coalesce(hl.losses, 0) as away_losses
from {{ ref("nba_teams") }} t
left join cte_wins w on w.winning_team = t.team_long
left join cte_losses l on l.losing_team = t.team_long
left join cte_favored_wins fw on fw.winning_team = t.team_long
left join cte_favored_losses fl on fl.losing_team = t.team_long
left join cte_avg_opponent_wins aw on aw.winning_team = t.team_long
left join cte_avg_opponent_losses al on al.losing_team = t.team_long
left join cte_home_wins hw on hw.home_team = t.team_long
left join cte_home_losses hl on hl.home_team = t.team_long
