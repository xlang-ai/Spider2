WITH drives_prelim AS (
  SELECT DISTINCT
    races."year",
    results."driver_id",
    races."round",
    results."constructor_id",
    COALESCE(
      CASE 
        WHEN results."constructor_id" = LAG(results."constructor_id") OVER (
          PARTITION BY races."year", results."driver_id"
          ORDER BY races."round" ASC
        ) THEN 0 
        ELSE 1 
      END, 1
    ) AS "is_first_race",
    COALESCE(
      CASE 
        WHEN results."constructor_id" = LEAD(results."constructor_id") OVER (
          PARTITION BY races."year", results."driver_id"
          ORDER BY races."round" ASC
        ) THEN 0 
        ELSE 1 
      END, 1
    ) AS "is_last_race"
  FROM 
      F1.F1.RESULTS results
  INNER JOIN F1.F1.RACES races ON races."race_id" = results."race_id"
),
first_last_races AS (
  SELECT
    "year",
    "driver_id",
    MIN("round") AS "first_round",
    MAX("round") AS "last_round"
  FROM 
      drives_prelim
  GROUP BY 
      "year", 
      "driver_id"
)
SELECT DISTINCT
  dp."driver_id"
FROM 
    drives_prelim dp
INNER JOIN first_last_races flr
  ON dp."year" = flr."year"
  AND dp."driver_id" = flr."driver_id"
  AND (dp."round" = flr."first_round" OR dp."round" = flr."last_round")
WHERE 
    dp."is_first_race" = 0
  AND dp."is_last_race" = 0
  AND dp."year" BETWEEN 1950 AND 1959
GROUP BY 
    dp."driver_id"
HAVING 
    COUNT(DISTINCT dp."round") > 1;
