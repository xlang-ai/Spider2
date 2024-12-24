
WITH COMBINED_RUNS AS (
    SELECT "match_id", "over_id", "ball_id", "innings_no", CAST("runs_scored" AS DOUBLE) AS "runs"
    FROM IPL.IPL.BATSMAN_SCORED
    UNION ALL
    SELECT "match_id", "over_id", "ball_id", "innings_no", CAST("extra_runs" AS DOUBLE) AS "runs"
    FROM IPL.IPL.EXTRA_RUNS
),
OVER_RUNS AS (
    SELECT "match_id", "innings_no", "over_id", SUM("runs") AS "runs_scored"
    FROM COMBINED_RUNS
    GROUP BY "match_id", "innings_no", "over_id"
),
MAX_OVER_RUNS AS (
    SELECT "match_id", MAX("runs_scored") AS "max_runs"
    FROM OVER_RUNS
    GROUP BY "match_id"
),
TOP_OVERS AS (
    SELECT o."match_id", o."innings_no", o."over_id", o."runs_scored"
    FROM OVER_RUNS o
    JOIN MAX_OVER_RUNS m ON o."match_id" = m."match_id" AND o."runs_scored" = m."max_runs"
),
TOP_BOWLERS AS (
    SELECT
        bb."match_id",
        t."runs_scored" AS "maximum_runs",
        bb."bowler"
    FROM IPL.IPL.BALL_BY_BALL bb
    JOIN TOP_OVERS t ON bb."match_id" = t."match_id"
    AND bb."innings_no" = t."innings_no"
    AND bb."over_id" = t."over_id"
    GROUP BY bb."match_id", t."runs_scored", bb."bowler"
)
SELECT
    b."match_id",
    p."player_name"
FROM (
    SELECT *
    FROM TOP_BOWLERS
    ORDER BY CAST("maximum_runs" AS DOUBLE) DESC
    LIMIT 3
) b
JOIN IPL.IPL.PLAYER p ON p."player_id" = b."bowler"
ORDER BY CAST(b."maximum_runs" AS DOUBLE) DESC, b."match_id", p."player_name";