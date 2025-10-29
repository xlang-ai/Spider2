WITH "years" AS (
  SELECT DISTINCT r."year"
  FROM "F1"."F1"."RACES" r
),
"final_races" AS (
  SELECT r."year", r."race_id"
  FROM "F1"."F1"."RACES" r
  JOIN (
    SELECT "year", MAX("round") AS "max_round"
    FROM "F1"."F1"."RACES"
    GROUP BY "year"
  ) lr
    ON r."year" = lr."year" AND r."round" = lr."max_round"
),
"driver_top_standings" AS (
  SELECT
    fr."year",
    ds."driver_id",
    d."full_name" AS "driver_full_name",
    ds."points"   AS "driver_points"
  FROM "F1"."F1"."DRIVER_STANDINGS" ds
  JOIN "final_races" fr
    ON ds."race_id" = fr."race_id"
  JOIN (
    SELECT fr."year", MAX(ds."points") AS "max_points"
    FROM "F1"."F1"."DRIVER_STANDINGS" ds
    JOIN "final_races" fr ON ds."race_id" = fr."race_id"
    GROUP BY fr."year"
  ) md
    ON fr."year" = md."year" AND ds."points" = md."max_points"
  LEFT JOIN "F1"."F1"."DRIVERS" d
    ON ds."driver_id" = d."driver_id"
),
"driver_points_agg" AS (
  SELECT
    r."year" AS "year",
    res."driver_id" AS "driver_id",
    SUM(COALESCE(res."points", 0)) AS "points"
  FROM "F1"."F1"."RESULTS" res
  JOIN "F1"."F1"."RACES" r
    ON res."race_id" = r."race_id"
  GROUP BY r."year", res."driver_id"
  UNION ALL
  SELECT
    r."year" AS "year",
    sr."driver_id" AS "driver_id",
    SUM(COALESCE(sr."points", 0)) AS "points"
  FROM "F1"."F1"."SPRINT_RESULTS" sr
  JOIN "F1"."F1"."RACES" r
    ON sr."race_id" = r."race_id"
  GROUP BY r."year", sr."driver_id"
),
"driver_points_summed" AS (
  SELECT "year", "driver_id", SUM("points") AS "points"
  FROM "driver_points_agg"
  GROUP BY "year", "driver_id"
),
"driver_top_results" AS (
  SELECT
    dp."year",
    dp."driver_id",
    d."full_name" AS "driver_full_name",
    dp."points"   AS "driver_points"
  FROM "driver_points_summed" dp
  JOIN (
    SELECT "year", MAX("points") AS "max_points"
    FROM "driver_points_summed"
    GROUP BY "year"
  ) md
    ON dp."year" = md."year" AND dp."points" = md."max_points"
  LEFT JOIN "F1"."F1"."DRIVERS" d
    ON dp."driver_id" = d."driver_id"
),
"driver_top_final" AS (
  SELECT
    y."year",
    COALESCE(dts."driver_id", dtr."driver_id")       AS "driver_id",
    COALESCE(dts."driver_full_name", dtr."driver_full_name") AS "driver_full_name"
  FROM "years" y
  LEFT JOIN "driver_top_standings" dts
    ON dts."year" = y."year"
  LEFT JOIN "driver_top_results" dtr
    ON dtr."year" = y."year" AND dts."year" IS NULL
),
"constructor_top_standings" AS (
  SELECT
    fr."year",
    cs."constructor_id",
    c."name" AS "constructor_name",
    cs."points" AS "constructor_points"
  FROM "F1"."F1"."CONSTRUCTOR_STANDINGS" cs
  JOIN "final_races" fr
    ON cs."race_id" = fr."race_id"
  JOIN (
    SELECT fr."year", MAX(cs."points") AS "max_points"
    FROM "F1"."F1"."CONSTRUCTOR_STANDINGS" cs
    JOIN "final_races" fr ON cs."race_id" = fr."race_id"
    GROUP BY fr."year"
  ) mc
    ON fr."year" = mc."year" AND cs."points" = mc."max_points"
  LEFT JOIN "F1"."F1"."CONSTRUCTORS" c
    ON cs."constructor_id" = c."constructor_id"
),
"constructor_points_agg" AS (
  SELECT
    r."year" AS "year",
    res."constructor_id" AS "constructor_id",
    SUM(COALESCE(res."points", 0)) AS "points"
  FROM "F1"."F1"."RESULTS" res
  JOIN "F1"."F1"."RACES" r
    ON res."race_id" = r."race_id"
  GROUP BY r."year", res."constructor_id"
  UNION ALL
  SELECT
    r."year" AS "year",
    sr."constructor_id" AS "constructor_id",
    SUM(COALESCE(sr."points", 0)) AS "points"
  FROM "F1"."F1"."SPRINT_RESULTS" sr
  JOIN "F1"."F1"."RACES" r
    ON sr."race_id" = r."race_id"
  GROUP BY r."year", sr."constructor_id"
),
"constructor_points_summed" AS (
  SELECT "year", "constructor_id", SUM("points") AS "points"
  FROM "constructor_points_agg"
  GROUP BY "year", "constructor_id"
),
"constructor_top_results" AS (
  SELECT
    cp."year",
    cp."constructor_id",
    c."name" AS "constructor_name",
    cp."points" AS "constructor_points"
  FROM "constructor_points_summed" cp
  JOIN (
    SELECT "year", MAX("points") AS "max_points"
    FROM "constructor_points_summed"
    GROUP BY "year"
  ) mc
    ON cp."year" = mc."year" AND cp."points" = mc."max_points"
  LEFT JOIN "F1"."F1"."CONSTRUCTORS" c
    ON cp."constructor_id" = c."constructor_id"
),
"constructor_top_final" AS (
  SELECT
    y."year",
    COALESCE(cts."constructor_id", ctr."constructor_id") AS "constructor_id",
    COALESCE(cts."constructor_name", ctr."constructor_name") AS "constructor_name"
  FROM "years" y
  LEFT JOIN "constructor_top_standings" cts
    ON cts."year" = y."year"
  LEFT JOIN "constructor_top_results" ctr
    ON ctr."year" = y."year" AND cts."year" IS NULL
)
SELECT
  y."year",
  dtf."driver_full_name",
  ctf."constructor_name"
FROM "years" y
LEFT JOIN "driver_top_final" dtf
  ON dtf."year" = y."year"
LEFT JOIN "constructor_top_final" ctf
  ON ctf."year" = y."year"
ORDER BY y."year" ASC;