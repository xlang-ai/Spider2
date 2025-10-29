WITH "curr" AS (
  SELECT "race_id", "lap", "driver_id", "position"
  FROM "F1"."F1"."LAP_POSITIONS"
  WHERE "lap_type" = 'Race' AND "lap" BETWEEN 1 AND 5
),
"prev_race" AS (
  SELECT "race_id", "lap", "driver_id", "position"
  FROM "F1"."F1"."LAP_POSITIONS"
  WHERE "lap_type" = 'Race' AND "lap" BETWEEN 1 AND 4
),
"grid" AS (
  SELECT "race_id", "driver_id", "grid"
  FROM "F1"."F1"."RESULTS"
),
"pairs_lap1" AS (
  SELECT
    c1."race_id",
    1 AS "lap",
    c1."driver_id" AS "overtaker_id",
    c2."driver_id" AS "overtaken_id",
    g1."grid" AS "grid_overtaker",
    g2."grid" AS "grid_overtaken",
    c1."position" AS "curr_pos_overtaker",
    c2."position" AS "curr_pos_overtaken"
  FROM "curr" c1
  JOIN "curr" c2
    ON c1."race_id" = c2."race_id"
   AND c1."lap" = 1 AND c2."lap" = 1
   AND c1."driver_id" != c2."driver_id"
  LEFT JOIN "grid" g1 ON g1."race_id" = c1."race_id" AND g1."driver_id" = c1."driver_id"
  LEFT JOIN "grid" g2 ON g2."race_id" = c2."race_id" AND g2."driver_id" = c2."driver_id"
  WHERE g1."grid" IS NOT NULL AND g2."grid" IS NOT NULL
    AND g1."grid" > g2."grid"
    AND c1."position" < c2."position"
),
"pairs_lap2to5" AS (
  SELECT
    c1."race_id",
    c1."lap" AS "lap",
    c1."driver_id" AS "overtaker_id",
    c2."driver_id" AS "overtaken_id",
    g1."grid" AS "grid_overtaker",
    g2."grid" AS "grid_overtaken"
  FROM "curr" c1
  JOIN "curr" c2
    ON c1."race_id" = c2."race_id"
   AND c1."lap" BETWEEN 2 AND 5
   AND c2."lap" = c1."lap"
   AND c1."driver_id" != c2."driver_id"
  JOIN "prev_race" p1 ON p1."race_id" = c1."race_id" AND p1."lap" = c1."lap" - 1 AND p1."driver_id" = c1."driver_id"
  JOIN "prev_race" p2 ON p2."race_id" = c2."race_id" AND p2."lap" = c2."lap" - 1 AND p2."driver_id" = c2."driver_id"
  LEFT JOIN "grid" g1 ON g1."race_id" = c1."race_id" AND g1."driver_id" = c1."driver_id"
  LEFT JOIN "grid" g2 ON g2."race_id" = c2."race_id" AND g2."driver_id" = c2."driver_id"
  WHERE p1."position" > p2."position"
    AND c1."position" < c2."position"
),
"all_pairs" AS (
  SELECT "race_id", "lap", "overtaker_id", "overtaken_id", "grid_overtaker", "grid_overtaken"
  FROM "pairs_lap1"
  UNION ALL
  SELECT "race_id", "lap", "overtaker_id", "overtaken_id", "grid_overtaker", "grid_overtaken"
  FROM "pairs_lap2to5"
),
"classified" AS (
  SELECT
    a."race_id",
    a."lap",
    a."overtaker_id",
    a."overtaken_id",
    CASE
      WHEN EXISTS (
        SELECT 1 FROM "F1"."F1"."RETIREMENTS" r
        WHERE r."race_id" = a."race_id"
          AND r."driver_id" = a."overtaken_id"
          AND r."lap" = a."lap"
      ) THEN 'R'
      WHEN EXISTS (
        SELECT 1 FROM "F1"."F1"."PIT_STOPS" ps
        WHERE ps."race_id" = a."race_id"
          AND ps."driver_id" = a."overtaken_id"
          AND (ps."lap" = a."lap" OR ps."lap" = a."lap" - 1)
      ) THEN 'P'
      WHEN a."lap" = 1
        AND a."grid_overtaker" IS NOT NULL
        AND a."grid_overtaken" IS NOT NULL
        AND abs(a."grid_overtaker" - a."grid_overtaken") <= 2 THEN 'S'
      ELSE 'T'
    END AS "category"
  FROM "all_pairs" a
)
SELECT
  CASE "category"
    WHEN 'R' THEN 'Retirements'
    WHEN 'P' THEN 'Pit Stops'
    WHEN 'S' THEN 'Start-Related'
    ELSE 'On-Track'
  END AS "category",
  COUNT(*) AS "overtakes"
FROM "classified"
GROUP BY "category"
ORDER BY CASE "category" WHEN 'Retirements' THEN 1 WHEN 'Pit Stops' THEN 2 WHEN 'Start-Related' THEN 3 ELSE 4 END;