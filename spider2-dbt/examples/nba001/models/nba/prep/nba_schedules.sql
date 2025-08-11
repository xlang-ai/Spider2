select *
from {{ ref("nba_reg_season_schedule") }}
union all
select *
from {{ ref("nba_post_season_schedule") }}




