WITH step_comp AS (
  SELECT
    "name",
    "version",
    "step",
    MAX(CASE WHEN "model" = 'Stack' THEN "test_score" END) AS "stack_score",
    MAX(CASE WHEN "model" != 'Stack' THEN "test_score" END) AS "max_non_stack"
  FROM "STACKING"."STACKING"."MODEL_SCORE"
  GROUP BY "name", "version", "step"
),
model_status AS (
  SELECT
    "name",
    "version",
    CASE
      WHEN MAX(CASE WHEN "stack_score" > "max_non_stack" THEN 1 ELSE 0 END) = 1 THEN 'strong'
      WHEN MAX(CASE WHEN "stack_score" = "max_non_stack" THEN 1 ELSE 0 END) = 1 THEN 'soft'
      ELSE NULL
    END AS "status"
  FROM step_comp
  WHERE "stack_score" IS NOT NULL AND "max_non_stack" IS NOT NULL
  GROUP BY "name", "version"
),
l1_per_model AS (
  SELECT
    "name",
    "version",
    "L1_model"
  FROM (
    SELECT
      "name",
      "version",
      "L1_model",
      COUNT(DISTINCT "step") AS "cnt",
      ROW_NUMBER() OVER (PARTITION BY "name", "version" ORDER BY COUNT(DISTINCT "step") DESC, "L1_model" ASC) AS "rn"
    FROM "STACKING"."STACKING"."MODEL"
    WHERE "L1_model" IS NOT NULL
    GROUP BY "name", "version", "L1_model"
  )
  WHERE "rn" = 1
),
status_l1_counts AS (
  SELECT
    ms."status",
    lpm."L1_model",
    COUNT(*) AS "occurrence_count"
  FROM model_status ms
  JOIN l1_per_model lpm
    ON ms."name" = lpm."name"
   AND ms."version" = lpm."version"
  WHERE ms."status" IN ('strong', 'soft')
  GROUP BY ms."status", lpm."L1_model"
),
top_l1_per_status AS (
  SELECT
    "status",
    "L1_model",
    "occurrence_count",
    RANK() OVER (PARTITION BY "status" ORDER BY "occurrence_count" DESC) AS "rnk"
  FROM status_l1_counts
)
SELECT
  "status",
  "L1_model",
  "occurrence_count"
FROM top_l1_per_status
WHERE "rnk" = 1
ORDER BY "status", "L1_model"