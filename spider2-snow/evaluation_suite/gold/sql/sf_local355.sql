WITH hiatus_prelim AS (
  SELECT DISTINCT
    races."year",
    driver_standings."driver_id",
    races."round",
    previous_results."constructor_id" AS "previous_constructor_id",
    next_results."constructor_id" AS "next_constructor_id",
    CASE
      WHEN previous_results."constructor_id" IS NOT NULL THEN 1
      ELSE 0
    END AS "is_first_race",
    CASE
      WHEN next_results."constructor_id" IS NOT NULL THEN 1
      ELSE 0
    END AS "is_last_race"
  FROM F1.F1.DRIVER_STANDINGS_EXT AS driver_standings
  INNER JOIN F1.F1.RACES_EXT AS races ON races."race_id" = driver_standings."race_id"
  LEFT JOIN F1.F1.RESULTS AS results
    ON results."race_id" = driver_standings."race_id"
    AND results."driver_id" = driver_standings."driver_id"
  LEFT JOIN F1.F1.RACES_EXT AS previous_race
    ON previous_race."year" = races."year"
    AND previous_race."round" = races."round" - 1
  LEFT JOIN F1.F1.RESULTS AS previous_results
    ON previous_results."race_id" = previous_race."race_id"
    AND previous_results."driver_id" = driver_standings."driver_id"
  LEFT JOIN F1.F1.RACES_EXT AS next_race
    ON next_race."year" = races."year"
    AND next_race."round" = races."round" + 1
  LEFT JOIN F1.F1.RESULTS AS next_results
    ON next_results."race_id" = next_race."race_id"
    AND next_results."driver_id" = driver_standings."driver_id"
  WHERE results."driver_id" IS NULL
),
first_race AS (
  SELECT
    "year",
    "driver_id",
    "round" AS "first_round",
    ROW_NUMBER() OVER (PARTITION BY "year", "driver_id" ORDER BY "round" ASC) AS "drive_id",
    "previous_constructor_id"
  FROM hiatus_prelim
  WHERE "is_first_race" = 1
),
last_race AS (
  SELECT
    "year",
    "driver_id",
    "round" AS "last_round",
    ROW_NUMBER() OVER (PARTITION BY "year", "driver_id" ORDER BY "round" ASC) AS "drive_id",
    "next_constructor_id"
  FROM hiatus_prelim
  WHERE "is_last_race" = 1
),
missed_races AS (
  SELECT
    "driver_id",
    "year",
    COUNT(*) AS "missed_count"  -- Count all missed rounds
  FROM hiatus_prelim
  GROUP BY "driver_id", "year"
  HAVING COUNT(*) < 3  -- Less than 3 missed rounds
)
SELECT
  AVG(first_race."first_round") AS "avg_first_round",
  AVG(last_race."last_round") AS "avg_last_round"
FROM F1.F1.DRIVER_STANDINGS_EXT AS driver_standings
INNER JOIN F1.F1.RACES_EXT AS races ON races."race_id" = driver_standings."race_id"
LEFT JOIN F1.F1.RESULTS AS results
  ON results."race_id" = driver_standings."race_id"
  AND results."driver_id" = driver_standings."driver_id"
INNER JOIN first_race
  ON first_race."year" = races."year"
  AND first_race."driver_id" = driver_standings."driver_id"
INNER JOIN last_race
  ON last_race."year" = races."year"
  AND last_race."driver_id" = driver_standings."driver_id"
  AND last_race."drive_id" = first_race."drive_id"
INNER JOIN missed_races
  ON missed_races."year" = races."year"
  AND missed_races."driver_id" = driver_standings."driver_id"
WHERE results."driver_id" IS NULL
  AND first_race."previous_constructor_id" != last_race."next_constructor_id";
