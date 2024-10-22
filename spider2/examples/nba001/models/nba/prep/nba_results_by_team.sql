from {{ ref("nba_results_log") }}
select
    game_id,
    'home' as team_type,
    hmtm as team,
    home_team as team_long,
    home_team_score as score,
    case when home_team = winning_team then 'WIN' else 'LOSS' end as game_results,
    home_team_score - visiting_team_score as margin,
    type
union all
from {{ ref("nba_results_log") }}
select
    game_id,
    'visitor' as team_type,
    vstm as team,
    visiting_team as team_long,
    visiting_team_score as score,
    case when visiting_team = winning_team then 'WIN' else 'LOSS' end as game_results,
    visiting_team_score - home_team_score as margin,
    type
