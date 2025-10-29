WITH "cte_app" AS (
  SELECT
    a."patent_id",
    MIN(TRY_TO_DATE(a."date")) AS "app_date"
  FROM "PATENTSVIEW"."PATENTSVIEW"."APPLICATION" a
  WHERE TRY_TO_DATE(a."date") IS NOT NULL
  GROUP BY a."patent_id"
),
"base" AS (
  SELECT DISTINCT
    p."id" AS "patent_id",
    p."number" AS "patent_number",
    ca."app_date" AS "application_date"
  FROM "PATENTSVIEW"."PATENTSVIEW"."PATENT" p
  JOIN "cte_app" ca
    ON ca."patent_id" = p."id"
  JOIN "PATENTSVIEW"."PATENTSVIEW"."CPC_CURRENT" cpc
    ON cpc."patent_id" = p."id"
  WHERE p."country" = 'US'
    AND cpc."category" = 'inventional'
),
"back_1y" AS (
  SELECT
    b."patent_id",
    COUNT(DISTINCT b."citation_id") AS "back_1y_count"
  FROM "PATENTSVIEW"."PATENTSVIEW"."USPATENTCITATION" b
  JOIN "base" ba
    ON ba."patent_id" = b."patent_id"
  JOIN "cte_app" app_cited
    ON app_cited."patent_id" = b."citation_id"
  WHERE app_cited."app_date" >= DATEADD(year, -1, ba."application_date")
    AND app_cited."app_date" < ba."application_date"
  GROUP BY b."patent_id"
),
"fwd_1y" AS (
  SELECT
    f."citation_id" AS "patent_id",
    COUNT(DISTINCT f."patent_id") AS "fwd_1y_count"
  FROM "PATENTSVIEW"."PATENTSVIEW"."USPATENTCITATION" f
  JOIN "base" ba
    ON ba."patent_id" = f."citation_id"
  JOIN "cte_app" app_citing
    ON app_citing."patent_id" = f."patent_id"
  WHERE app_citing."app_date" >= ba."application_date"
    AND app_citing."app_date" <= DATEADD(year, 1, ba."application_date")
  GROUP BY f."citation_id"
),
"fwd_3y" AS (
  SELECT
    f."citation_id" AS "patent_id",
    COUNT(DISTINCT f."patent_id") AS "fwd_3y_count"
  FROM "PATENTSVIEW"."PATENTSVIEW"."USPATENTCITATION" f
  JOIN "base" ba
    ON ba."patent_id" = f."citation_id"
  JOIN "cte_app" app_citing
    ON app_citing."patent_id" = f."patent_id"
  WHERE app_citing."app_date" >= ba."application_date"
    AND app_citing."app_date" <= DATEADD(year, 3, ba."application_date")
  GROUP BY f."citation_id"
)
SELECT
  b."patent_id",
  b."patent_number",
  b."application_date",
  COALESCE(bk."back_1y_count", 0) AS "backward_citations_within_1y_before_app",
  COALESCE(f1."fwd_1y_count", 0) AS "forward_citations_within_1y_after_app",
  COALESCE(f3."fwd_3y_count", 0) AS "forward_citations_within_3y_after_app"
FROM "base" b
LEFT JOIN "back_1y" bk
  ON bk."patent_id" = b."patent_id"
LEFT JOIN "fwd_1y" f1
  ON f1."patent_id" = b."patent_id"
LEFT JOIN "fwd_3y" f3
  ON f3."patent_id" = b."patent_id"
WHERE COALESCE(bk."back_1y_count", 0) > 0
  AND COALESCE(f1."fwd_1y_count", 0) > 0
ORDER BY bk."back_1y_count" DESC
LIMIT 1;