WITH "ages" AS (
  SELECT 12 AS "Age" UNION ALL
  SELECT 13 UNION ALL
  SELECT 14 UNION ALL
  SELECT 15 UNION ALL
  SELECT 16 UNION ALL
  SELECT 17 UNION ALL
  SELECT 18
),
"vehicle_deaths" AS (
  SELECT DISTINCT
    "dr"."Id" AS "dr_id",
    "dr"."Age" AS "Age",
    CASE WHEN "r"."Description" ILIKE '%black%' THEN 1 ELSE 0 END AS "is_black"
  FROM "DEATH"."DEATH"."ENTITYAXISCONDITIONS" AS "e"
  JOIN "DEATH"."DEATH"."ICD10CODE" AS "icd"
    ON "icd"."Code" = "e"."Icd10Code"
  JOIN "DEATH"."DEATH"."DEATHRECORDS" AS "dr"
    ON "dr"."Id" = "e"."DeathRecordId"
  LEFT JOIN "DEATH"."DEATH"."RACE" AS "r"
    ON "r"."Code" = "dr"."Race"
  WHERE "dr"."AgeType" = 1
    AND "dr"."Age" BETWEEN 12 AND 18
    AND "icd"."Description" ILIKE '%vehicle%'
),
"vehicle_agg" AS (
  SELECT
    "Age",
    COUNT(DISTINCT "dr_id") AS "vehicle_total_deaths",
    COUNT(DISTINCT CASE WHEN "is_black" = 1 THEN "dr_id" END) AS "vehicle_black_deaths"
  FROM "vehicle_deaths"
  GROUP BY "Age"
),
"firearm_deaths" AS (
  SELECT DISTINCT
    "dr"."Id" AS "dr_id",
    "dr"."Age" AS "Age",
    CASE WHEN "r"."Description" ILIKE '%black%' THEN 1 ELSE 0 END AS "is_black"
  FROM "DEATH"."DEATH"."ENTITYAXISCONDITIONS" AS "e"
  JOIN "DEATH"."DEATH"."ICD10CODE" AS "icd"
    ON "icd"."Code" = "e"."Icd10Code"
  JOIN "DEATH"."DEATH"."DEATHRECORDS" AS "dr"
    ON "dr"."Id" = "e"."DeathRecordId"
  LEFT JOIN "DEATH"."DEATH"."RACE" AS "r"
    ON "r"."Code" = "dr"."Race"
  WHERE "dr"."AgeType" = 1
    AND "dr"."Age" BETWEEN 12 AND 18
    AND "icd"."Description" ILIKE '%firearm%'
),
"firearm_agg" AS (
  SELECT
    "Age",
    COUNT(DISTINCT "dr_id") AS "firearm_total_deaths",
    COUNT(DISTINCT CASE WHEN "is_black" = 1 THEN "dr_id" END) AS "firearm_black_deaths"
  FROM "firearm_deaths"
  GROUP BY "Age"
)
SELECT
  "a"."Age",
  COALESCE("v"."vehicle_total_deaths", 0) AS "vehicle_total_deaths",
  COALESCE("v"."vehicle_black_deaths", 0) AS "vehicle_black_deaths",
  COALESCE("f"."firearm_total_deaths", 0) AS "firearm_total_deaths",
  COALESCE("f"."firearm_black_deaths", 0) AS "firearm_black_deaths"
FROM "ages" AS "a"
LEFT JOIN "vehicle_agg" AS "v"
  ON "v"."Age" = "a"."Age"
LEFT JOIN "firearm_agg" AS "f"
  ON "f"."Age" = "a"."Age"
ORDER BY "a"."Age"