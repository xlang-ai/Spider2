select c.*
from
    (
        select a.season, a.team1 as team
        from {{ ref("nba_elo_history") }} a
        union all
        select b.season, b.team2
        from {{ ref("nba_elo_history") }} b
    ) as c
group by all
order by c.team
