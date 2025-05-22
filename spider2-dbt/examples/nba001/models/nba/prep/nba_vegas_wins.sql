select team, win_total::double as win_total from {{ ref("nba_ratings") }} group by all
