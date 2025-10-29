WITH "base" AS (
  SELECT DISTINCT
    UPPER("fa"."VALUE":"name"::string) AS "assignee_name",
    "p"."application_number" AS "application_number",
    CASE WHEN "p"."filing_date" IS NOT NULL AND "p"."filing_date" > 0 THEN FLOOR("p"."filing_date"/10000) END AS "filing_year",
    "p"."country_code" AS "country_code"
  FROM "PATENTS"."PATENTS"."PUBLICATIONS" AS "p",
       LATERAL FLATTEN(input => "p"."cpc") AS "fc",
       LATERAL FLATTEN(input => "p"."assignee_harmonized") AS "fa"
  WHERE UPPER("fc"."VALUE":"code"::string) LIKE 'A01B3%'
),
"assignee_totals" AS (
  SELECT
    "assignee_name",
    COUNT(DISTINCT "application_number") AS "total_applications"
  FROM "base"
  GROUP BY "assignee_name"
),
"per_year" AS (
  SELECT
    "assignee_name",
    "filing_year",
    COUNT(DISTINCT "application_number") AS "apps_in_year"
  FROM "base"
  WHERE "filing_year" IS NOT NULL
  GROUP BY "assignee_name", "filing_year"
),
"top_year" AS (
  SELECT
    "assignee_name",
    "filing_year" AS "top_year",
    "apps_in_year"
  FROM (
    SELECT
      "assignee_name",
      "filing_year",
      "apps_in_year",
      ROW_NUMBER() OVER (PARTITION BY "assignee_name" ORDER BY "apps_in_year" DESC, "filing_year" ASC) AS "rn"
    FROM "per_year"
  )
  WHERE "rn" = 1
),
"per_country_year" AS (
  SELECT
    "assignee_name",
    "filing_year",
    "country_code",
    COUNT(DISTINCT "application_number") AS "apps_in_year_country"
  FROM "base"
  WHERE "filing_year" IS NOT NULL
  GROUP BY "assignee_name", "filing_year", "country_code"
),
"top_country" AS (
  SELECT
    "pc"."assignee_name",
    "pc"."filing_year",
    "pc"."country_code" AS "top_country_code",
    "pc"."apps_in_year_country"
  FROM (
    SELECT
      "assignee_name",
      "filing_year",
      "country_code",
      "apps_in_year_country",
      ROW_NUMBER() OVER (PARTITION BY "assignee_name", "filing_year" ORDER BY "apps_in_year_country" DESC, "country_code" ASC) AS "rn"
    FROM "per_country_year"
  ) AS "pc"
  WHERE "pc"."rn" = 1
),
"ranked_assignees" AS (
  SELECT
    "assignee_name",
    "total_applications",
    ROW_NUMBER() OVER (ORDER BY "total_applications" DESC, "assignee_name" ASC) AS "assignee_rank"
  FROM "assignee_totals"
)
SELECT
  "r"."assignee_name",
  "r"."total_applications",
  "y"."top_year",
  "y"."apps_in_year" AS "applications_in_top_year",
  "c"."top_country_code"
FROM "ranked_assignees" AS "r"
JOIN "top_year" AS "y"
  ON "r"."assignee_name" = "y"."assignee_name"
LEFT JOIN "top_country" AS "c"
  ON "c"."assignee_name" = "y"."assignee_name"
 AND "c"."filing_year" = "y"."top_year"
WHERE "r"."assignee_rank" <= 3
ORDER BY "r"."total_applications" DESC, "r"."assignee_name" ASC;