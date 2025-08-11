WITH mst_fallout_step AS (
  -- Define the stages and paths
  SELECT 
      1 AS "step", '/regist/input' AS "path"
  UNION ALL
  SELECT 
      2 AS "step", '/regist/confirm' AS "path"
),
form_log_with_fallout_step AS (
  SELECT
      l."session",
      m."step",
      m."path",
      MAX(l."stamp") AS "max_stamp",
      MIN(l."stamp") AS "min_stamp"
  FROM
      mst_fallout_step AS m
      JOIN LOG.LOG.FORM_LOG AS l
      ON m."path" = l."path"
  WHERE 
      l."status" = ''
  GROUP BY 
      l."session", m."step", m."path"
),
form_log_with_mod_fallout_step AS (
  SELECT
      "session",
      "step",
      "path",
      "max_stamp",
      (
          SELECT MIN("min_stamp")
          FROM 
              form_log_with_fallout_step AS prev
          WHERE 
              prev."session" = curr."session" 
              AND prev."step" = curr."step" - 1
      ) AS "lag_min_stamp",
      (
          SELECT 
              MIN("step") 
          FROM 
              form_log_with_fallout_step AS min_step
          WHERE 
              min_step."session" = curr."session"
      ) AS "min_step",
      (
          SELECT 
              COUNT(*)
          FROM 
              form_log_with_fallout_step AS count_step
          WHERE 
              count_step."session" = curr."session" 
              AND count_step."step" <= curr."step"
      ) AS "cum_count"
  FROM 
      form_log_with_fallout_step AS curr
),
fallout_log AS (
  SELECT
    "session",
    "step",
    "path",
    "max_stamp"
  FROM 
    form_log_with_mod_fallout_step
  WHERE 
    "min_step" = 1
    AND "step" = "cum_count"
    AND ("lag_min_stamp" IS NULL OR "max_stamp" >= "lag_min_stamp")
),
input_to_confirm_counts AS (
  SELECT
    COUNT(DISTINCT input."session") AS "count"
  FROM 
    fallout_log AS input
  JOIN 
    fallout_log AS confirm
  ON 
    input."session" = confirm."session"
  WHERE 
    input."path" = '/regist/input'
    AND confirm."path" = '/regist/confirm'
    AND input."max_stamp" < confirm."max_stamp"
)
SELECT
  "count"
FROM 
  input_to_confirm_counts;
