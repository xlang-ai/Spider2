with "PLAYER_RUNS" as (
  select
    "B"."match_id",
    "B"."striker" as "player_id",
    sum("BS"."runs_scored") as "runs"
  from "IPL"."IPL"."BALL_BY_BALL" "B"
  join "IPL"."IPL"."BATSMAN_SCORED" "BS"
    on "B"."match_id" = "BS"."match_id"
   and "B"."over_id" = "BS"."over_id"
   and "B"."ball_id" = "BS"."ball_id"
   and "B"."innings_no" = "BS"."innings_no"
  group by "B"."match_id", "B"."striker"
)
select distinct "P"."player_name"
from "PLAYER_RUNS" "PR"
join "IPL"."IPL"."PLAYER_MATCH" "PM"
  on "PM"."match_id" = "PR"."match_id"
 and "PM"."player_id" = "PR"."player_id"
join "IPL"."IPL"."MATCH" "M"
  on "M"."match_id" = "PR"."match_id"
join "IPL"."IPL"."PLAYER" "P"
  on "P"."player_id" = "PR"."player_id"
where "PR"."runs" >= 100
  and "M"."match_winner" is not null
  and "PM"."team_id" in ("M"."team_1", "M"."team_2")
  and "PM"."team_id" != "M"."match_winner"