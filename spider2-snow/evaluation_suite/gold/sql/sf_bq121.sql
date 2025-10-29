WITH
  ref AS (
    SELECT DATE '2021-10-01' AS "ref_date"
  ),
  users_base AS (
    SELECT
      "id" AS "user_id",
      CAST(TO_TIMESTAMP("creation_date" / 1000000.0) AS DATE) AS "creation_date_dt",
      "reputation"
    FROM "STACKOVERFLOW"."STACKOVERFLOW"."USERS"
  ),
  users_filtered AS (
    SELECT ub.*
    FROM users_base ub
    JOIN ref r ON 1=1
    WHERE ub."creation_date_dt" <= r."ref_date"
  ),
  users_years AS (
    SELECT
      "user_id",
      "creation_date_dt",
      "reputation",
      (DATEDIFF(year, "creation_date_dt", r."ref_date")
        - CASE WHEN DATEADD(year, DATEDIFF(year, "creation_date_dt", r."ref_date"), "creation_date_dt") > r."ref_date" THEN 1 ELSE 0 END
      ) AS "complete_years"
    FROM users_filtered uf
    JOIN ref r ON 1=1
  ),
  badges_per_user AS (
    SELECT
      "user_id",
      COUNT(*) AS "num_badges"
    FROM "STACKOVERFLOW"."STACKOVERFLOW"."BADGES"
    GROUP BY "user_id"
  )
SELECT
  uy."complete_years" AS "complete_years",
  COALESCE(CAST(AVG(uy."reputation") AS FLOAT), 0) AS "avg_reputation",
  COALESCE(CAST(AVG(COALESCE(b."num_badges", 0)) AS FLOAT), 0) AS "avg_badges",
  COUNT(*) AS "user_count"
FROM users_years uy
LEFT JOIN badges_per_user b
  ON uy."user_id" = b."user_id"
GROUP BY uy."complete_years"
ORDER BY uy."complete_years" ASC;