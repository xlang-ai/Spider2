select r.team_long, r.team, tournament_group, conf, alt_key
from {{ ref("nba_raw_team_ratings") }} r





