WITH "moto_collisions" AS (
  SELECT
    "case_id",
    COALESCE("motorcyclist_killed_count", 0) AS "motorcyclist_killed_count"
  FROM "CALIFORNIA_TRAFFIC_COLLISION"."CALIFORNIA_TRAFFIC_COLLISION"."COLLISIONS"
  WHERE COALESCE("motorcycle_collision", 0) = 1
),
"moto_party_helmet" AS (
  SELECT
    p."case_id",
    MAX(
      CASE
        WHEN (
          (LOWER(COALESCE(p."party_safety_equipment_1", '')) LIKE '%helmet%' AND LOWER(COALESCE(p."party_safety_equipment_1", '')) NOT LIKE '%not%' AND LOWER(COALESCE(p."party_safety_equipment_1", '')) NOT LIKE '%no helmet%')
          OR
          (LOWER(COALESCE(p."party_safety_equipment_2", '')) LIKE '%helmet%' AND LOWER(COALESCE(p."party_safety_equipment_2", '')) NOT LIKE '%not%' AND LOWER(COALESCE(p."party_safety_equipment_2", '')) NOT LIKE '%no helmet%')
        ) THEN 1 ELSE 0
      END
    ) AS "worn_any",
    MAX(
      CASE
        WHEN (
          (LOWER(COALESCE(p."party_safety_equipment_1", '')) LIKE '%helmet%' AND (LOWER(COALESCE(p."party_safety_equipment_1", '')) LIKE '%not%' OR LOWER(COALESCE(p."party_safety_equipment_1", '')) LIKE '%no helmet%'))
          OR
          (LOWER(COALESCE(p."party_safety_equipment_2", '')) LIKE '%helmet%' AND (LOWER(COALESCE(p."party_safety_equipment_2", '')) LIKE '%not%' OR LOWER(COALESCE(p."party_safety_equipment_2", '')) LIKE '%no helmet%'))
        ) THEN 1 ELSE 0
      END
    ) AS "not_worn_any"
  FROM "CALIFORNIA_TRAFFIC_COLLISION"."CALIFORNIA_TRAFFIC_COLLISION"."PARTIES" p
  INNER JOIN "moto_collisions" mc
    ON mc."case_id" = p."case_id"
  WHERE LOWER(COALESCE(p."statewide_vehicle_type", '')) LIKE '%motorcycle%'
  GROUP BY p."case_id"
),
"classified" AS (
  SELECT
    mc."case_id",
    mc."motorcyclist_killed_count",
    CASE
      WHEN mph."worn_any" = 1 AND COALESCE(mph."not_worn_any", 0) = 0 THEN 'helmet_worn'
      WHEN mph."not_worn_any" = 1 AND COALESCE(mph."worn_any", 0) = 0 THEN 'no_helmet'
      ELSE NULL
    END AS "helmet_group"
  FROM "moto_collisions" mc
  LEFT JOIN "moto_party_helmet" mph
    ON mc."case_id" = mph."case_id"
)
SELECT
  'helmet_worn' AS "helmet_usage",
  COALESCE(
    100.0 * SUM(CASE WHEN "helmet_group" = 'helmet_worn' THEN "motorcyclist_killed_count" ELSE 0 END)
    / NULLIF(SUM(CASE WHEN "helmet_group" = 'helmet_worn' THEN 1 ELSE 0 END), 0),
    0
  ) AS "fatality_percentage"
FROM "classified"
UNION ALL
SELECT
  'no_helmet' AS "helmet_usage",
  COALESCE(
    100.0 * SUM(CASE WHEN "helmet_group" = 'no_helmet' THEN "motorcyclist_killed_count" ELSE 0 END)
    / NULLIF(SUM(CASE WHEN "helmet_group" = 'no_helmet' THEN 1 ELSE 0 END), 0),
    0
  ) AS "fatality_percentage"
FROM "classified";