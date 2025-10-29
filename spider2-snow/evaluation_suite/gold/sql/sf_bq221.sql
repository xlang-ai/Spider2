WITH RECURSIVE
base AS (
  SELECT
    p."application_number",
    FLOOR(p."filing_date"/10000) AS "filing_year",
    f."VALUE":"code"::string AS "cpc_code",
    f."INDEX" AS "idx",
    ROW_NUMBER() OVER (PARTITION BY p."application_number" ORDER BY f."INDEX") AS "rn"
  FROM "PATENTS"."PATENTS"."PUBLICATIONS" p,
       LATERAL FLATTEN(input => p."cpc") f
  WHERE p."application_number" IS NOT NULL
    AND p."application_number" != ''
    AND p."filing_date" IS NOT NULL
    AND p."filing_date" > 0
    AND f."VALUE":"first"::boolean = true
),
pub_first AS (
  SELECT
    "application_number",
    "filing_year",
    "cpc_code"
  FROM base
  WHERE "rn" = 1
),
map_group AS (
  SELECT
    pf."application_number",
    pf."filing_year",
    anc."symbol" AS "group_symbol",
    anc."titleFull" AS "group_title"
  FROM pub_first pf
  JOIN "PATENTS"."PATENTS"."CPC_DEFINITION" cd
    ON cd."symbol" = pf."cpc_code"
  , LATERAL FLATTEN(input => ARRAY_CAT(ARRAY_CONSTRUCT(cd."symbol"), cd."parents")) par
  JOIN "PATENTS"."PATENTS"."CPC_DEFINITION" anc
    ON anc."symbol" = par."VALUE"::string
   AND anc."level" = 5
),
yearly_counts AS (
  SELECT
    "group_symbol",
    "group_title",
    "filing_year" AS "year",
    COUNT(DISTINCT "application_number") AS "filings"
  FROM map_group
  GROUP BY 1,2,3
),
group_years AS (
  SELECT
    yc."group_symbol",
    yc."group_title",
    MIN(yc."year") AS "min_year",
    MAX(yc."year") AS "max_year"
  FROM yearly_counts yc
  GROUP BY 1,2
),
series AS (
  SELECT
    gy."group_symbol",
    gy."group_title",
    v."VALUE"::int AS "year"
  FROM group_years gy,
       LATERAL FLATTEN(input => ARRAY_GENERATE_RANGE(gy."min_year", gy."max_year" + 1)) v
),
series_counts AS (
  SELECT
    s."group_symbol",
    s."group_title",
    s."year",
    COALESCE(yc."filings", 0) AS "filings"
  FROM series s
  LEFT JOIN yearly_counts yc
    ON yc."group_symbol" = s."group_symbol"
   AND yc."year" = s."year"
),
ordered AS (
  SELECT
    "group_symbol",
    "group_title",
    "year",
    "filings",
    ROW_NUMBER() OVER (PARTITION BY "group_symbol" ORDER BY "year") AS "ord"
  FROM series_counts
),
r AS (
  SELECT
    o."group_symbol",
    o."group_title",
    o."year",
    o."filings",
    o."filings"::float AS "ema",
    o."ord"
  FROM ordered o
  WHERE o."ord" = 1
  UNION ALL
  SELECT
    o."group_symbol",
    o."group_title",
    o."year",
    o."filings",
    0.2 * o."filings" + 0.8 * r."ema" AS "ema",
    o."ord"
  FROM ordered o
  JOIN r
    ON o."group_symbol" = r."group_symbol"
   AND o."ord" = r."ord" + 1
),
best_year AS (
  SELECT
    "group_symbol",
    "group_title",
    "year" AS "best_year",
    "ema" AS "max_ema",
    ROW_NUMBER() OVER (PARTITION BY "group_symbol" ORDER BY "ema" DESC, "year" ASC) AS "rn"
  FROM r
)
SELECT
  "group_symbol",
  "group_title",
  "best_year",
  "max_ema"
FROM best_year
WHERE "rn" = 1
ORDER BY "max_ema" DESC, "group_symbol" ASC;