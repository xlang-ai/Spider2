with
    cte_base as (select * from 'dlt/data/nba/nba_data/games/*.csv'),
    cte_seed as (select * from 'data/nba/nba_results.csv')
select
    coalesce(a.date, strptime(b."Date", '%a %b %-d %Y'))::date as "date",
    b."Start (ET)" as "Start (ET)",
    coalesce(away.team_long, b."Visitor/Neutral") as "VisTm",
    coalesce(a.away_points, b.pts)::int as visiting_team_score,
    coalesce(home.team_long, b."Home/Neutral") as "HomeTm",
    coalesce(a.home_points, b.pts_1)::int as home_team_score,
    b."Attend." as "Attend.",
    b.arena as arena,
    b.notes as notes,
    case
        when visiting_team_score > home_team_score then vistm else hometm
    end as winner,
    case when visiting_team_score > home_team_score then hometm else vistm end as loser,
    case
        when visiting_team_score > home_team_score
        then visiting_team_score
        else home_team_score
    end as winner_pts,
    case
        when visiting_team_score > home_team_score
        then home_team_score
        else visiting_team_score
    end as loser_pts
from cte_base a
left join
    "nba"."main"."nba_raw_team_ratings" home on home.alt_key = a.home_team_abbreviation
left join
    "nba"."main"."nba_raw_team_ratings" away on away.alt_key = a.away_team_abbreviation
full outer join
    cte_seed b
    on strptime(b."Date", '%a %b %-d %Y')::date = a.date
    and b."Home/Neutral" = home.team_long
where a.date <= '2024-04-15'