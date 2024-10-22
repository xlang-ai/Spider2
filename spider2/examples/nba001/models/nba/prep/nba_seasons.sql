select a.season from {{ ref("nba_elo_history") }} a group by all order by a.season
