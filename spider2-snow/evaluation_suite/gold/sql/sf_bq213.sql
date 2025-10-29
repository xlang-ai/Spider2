WITH "filtered" AS (
  SELECT p."publication_number", p."ipc"
  FROM "PATENTS"."PATENTS"."PUBLICATIONS" p
  WHERE p."country_code" = 'US'
    AND p."kind_code" = 'B2'
    AND p."grant_date" BETWEEN 20220601 AND 20220831
),
"flat" AS (
  SELECT
    fpub."publication_number",
    SUBSTRING(f.value:"code"::string, 1, 4) AS "ipc4",
    CASE WHEN f.value:"first"::boolean = TRUE THEN 1 ELSE 0 END AS "is_first"
  FROM "filtered" fpub,
       LATERAL FLATTEN(input => fpub."ipc") f
  WHERE f.value:"code" IS NOT NULL
    AND SUBSTRING(f.value:"code"::string, 1, 4) <> ''
),
"agg" AS (
  SELECT
    "publication_number",
    "ipc4",
    COUNT(*) AS "cnt_all",
    MAX("is_first") AS "has_first"
  FROM "flat"
  GROUP BY "publication_number", "ipc4"
),
"ranked" AS (
  SELECT
    "publication_number",
    "ipc4",
    ROW_NUMBER() OVER (
      PARTITION BY "publication_number"
      ORDER BY "has_first" DESC, "cnt_all" DESC, "ipc4" ASC
    ) AS "rn"
  FROM "agg"
)
SELECT
  "ipc4" AS "most_common_ipc4",
  COUNT(*) AS "num_publications"
FROM "ranked"
WHERE "rn" = 1
GROUP BY "ipc4"
ORDER BY "num_publications" DESC, "ipc4" ASC
LIMIT 1;