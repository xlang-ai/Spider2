-- Status: Finished in turn 6.

WITH over_runs AS (
  SELECT 
    "bbb"."match_id",
    "bbb"."over_id",
    "bbb"."bowler",
    COALESCE(SUM("bs"."runs_scored"), 0) + COALESCE(SUM("er"."extra_runs"), 0) AS "total_runs_conceded"
  FROM "IPL"."IPL"."BALL_BY_BALL" "bbb"
  LEFT JOIN "IPL"."IPL"."BATSMAN_SCORED" "bs" 
    ON "bbb"."match_id" = "bs"."match_id" 
    AND "bbb"."innings_no" = "bs"."innings_no"
    AND "bbb"."over_id" = "bs"."over_id"
    AND "bbb"."ball_id" = "bs"."ball_id"
  LEFT JOIN "IPL"."IPL"."EXTRA_RUNS" "er"
    ON "bbb"."match_id" = "er"."match_id"
    AND "bbb"."innings_no" = "er"."innings_no" 
    AND "bbb"."over_id" = "er"."over_id"
    AND "bbb"."ball_id" = "er"."ball_id"
  GROUP BY "bbb"."match_id", "bbb"."over_id", "bbb"."bowler"
),
max_runs_per_match AS (
  SELECT 
    "match_id",
    MAX("total_runs_conceded") AS "max_runs_conceded_in_single_over"
  FROM over_runs
  GROUP BY "match_id"
),
worst_bowlers_per_match AS (
  SELECT 
    "or"."match_id",
    "or"."bowler",
    "or"."over_id",
    "or"."total_runs_conceded"
  FROM over_runs "or"
  INNER JOIN max_runs_per_match "mrpm"
    ON "or"."match_id" = "mrpm"."match_id"
    AND "or"."total_runs_conceded" = "mrpm"."max_runs_conceded_in_single_over"
),
top_3_worst_bowlers AS (
  SELECT 
    "match_id",
    "bowler",
    "over_id",
    "total_runs_conceded",
    ROW_NUMBER() OVER (ORDER BY "total_runs_conceded" DESC) AS "rank"
  FROM worst_bowlers_per_match
)
SELECT 
  "p"."player_name",
  "t3wb"."total_runs_conceded",
  "t3wb"."match_id"
FROM top_3_worst_bowlers "t3wb"
INNER JOIN "IPL"."IPL"."PLAYER" "p"
  ON "t3wb"."bowler" = "p"."player_id"
WHERE "t3wb"."rank" <= 3