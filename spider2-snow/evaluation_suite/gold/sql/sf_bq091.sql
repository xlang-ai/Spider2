WITH a61_applications AS (
  SELECT DISTINCT p."application_number"
  FROM "PATENTS"."PATENTS"."PUBLICATIONS" p, LATERAL FLATTEN(input => p."cpc") c
  WHERE p."filing_date" IS NOT NULL
    AND p."filing_date" > 0
    AND c.value:"code"::string LIKE 'A61%'
    AND p."application_number" IS NOT NULL
  UNION
  SELECT DISTINCT p."application_number"
  FROM "PATENTS"."PATENTS"."PUBLICATIONS" p, LATERAL FLATTEN(input => p."ipc") i
  WHERE p."filing_date" IS NOT NULL
    AND p."filing_date" > 0
    AND i.value:"code"::string LIKE 'A61%'
    AND p."application_number" IS NOT NULL
),
apps_with_meta AS (
  SELECT
    p."application_number",
    CAST(FLOOR(p."filing_date" / 10000) AS INTEGER) AS "filing_year",
    p."assignee_harmonized",
    p."assignee"
  FROM "PATENTS"."PATENTS"."PUBLICATIONS" p
  JOIN a61_applications a ON a."application_number" = p."application_number"
),
assignee_apps AS (
  SELECT
    UPPER(TRIM(ah.value:"name"::string)) AS "assignee_name",
    awm."application_number",
    awm."filing_year"
  FROM apps_with_meta awm,
       LATERAL FLATTEN(input => awm."assignee_harmonized") ah
  WHERE ah.value:"name" IS NOT NULL

  UNION ALL

  SELECT
    UPPER(TRIM(a.value::string)) AS "assignee_name",
    awm."application_number",
    awm."filing_year"
  FROM apps_with_meta awm,
       LATERAL FLATTEN(input => awm."assignee") a
  WHERE (awm."assignee_harmonized" IS NULL OR ARRAY_SIZE(awm."assignee_harmonized") = 0)
    AND a.value IS NOT NULL
),
assignee_totals AS (
  SELECT
    "assignee_name",
    COUNT(DISTINCT "application_number") AS "total_apps"
  FROM assignee_apps
  GROUP BY "assignee_name"
),
top_assignee AS (
  SELECT "assignee_name"
  FROM assignee_totals
  QUALIFY ROW_NUMBER() OVER (ORDER BY "total_apps" DESC, "assignee_name" ASC) = 1
),
year_counts AS (
  SELECT
    aa."filing_year" AS "year",
    COUNT(DISTINCT aa."application_number") AS "cnt"
  FROM assignee_apps aa
  JOIN top_assignee ta ON aa."assignee_name" = ta."assignee_name"
  GROUP BY aa."filing_year"
)
SELECT "year"
FROM year_counts
QUALIFY ROW_NUMBER() OVER (ORDER BY "cnt" DESC, "year" ASC) = 1;