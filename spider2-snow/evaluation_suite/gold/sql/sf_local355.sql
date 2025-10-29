WITH "driver_races" AS (
  SELECT
    "res"."driver_id" AS "driver_id",
    "r"."year" AS "year",
    "r"."round" AS "round",
    "res"."constructor_id" AS "constructor_id",
    LEAD("r"."round") OVER (PARTITION BY "res"."driver_id", "r"."year" ORDER BY "r"."round") AS "next_round",
    LEAD("res"."constructor_id") OVER (PARTITION BY "res"."driver_id", "r"."year" ORDER BY "r"."round") AS "next_constructor"
  FROM "F1"."F1"."RESULTS" AS "res"
  JOIN "F1"."F1"."RACES" AS "r"
    ON "res"."race_id" = "r"."race_id"
),
"hiatus" AS (
  SELECT
    "driver_id",
    "year",
    "round",
    "constructor_id",
    "next_round",
    "next_constructor",
    "next_round" - "round" - 1 AS "races_missed",
    "round" + 1 AS "first_missed_round",
    "next_round" - 1 AS "last_missed_round"
  FROM "driver_races"
  WHERE "next_round" IS NOT NULL
    AND "next_round" - "round" - 1 > 0
)
SELECT
  AVG("first_missed_round") AS "avg_first_missed_round",
  AVG("last_missed_round") AS "avg_last_missed_round"
FROM "hiatus"
WHERE "races_missed" < 3
  AND "constructor_id" IS NOT NULL
  AND "next_constructor" IS NOT NULL
  AND "constructor_id" != "next_constructor"