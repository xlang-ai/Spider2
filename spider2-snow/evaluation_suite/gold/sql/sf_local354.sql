
SELECT
  d."full_name" AS name,
  t."year" AS year,
  c."name" AS constructor_name,
  t.num_unique_rounds AS num_unique_rounds
FROM (
  SELECT
    r."driver_id",
    ra."year",
    MIN_BY(r."constructor_id", ra."round") AS first_constructor_id,
    MAX_BY(r."constructor_id", ra."round") AS last_constructor_id,
    COUNT(DISTINCT ra."round") AS num_unique_rounds
  FROM F1.F1.RESULTS r
  JOIN F1.F1.RACES ra ON r."race_id" = ra."race_id"
  WHERE ra."year" BETWEEN 1950 AND 1959
  GROUP BY r."driver_id", ra."year"
  HAVING
    COUNT(DISTINCT ra."round") >= 2
    AND MIN_BY(r."constructor_id", ra."round") = MAX_BY(r."constructor_id", ra."round")
) t
JOIN F1.F1.DRIVERS d ON t."driver_id" = d."driver_id"
JOIN F1.F1.CONSTRUCTORS c ON t.first_constructor_id = c."constructor_id"
ORDER BY name, year
