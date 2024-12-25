WITH fam AS (
  SELECT DISTINCT
    "family_id"
  FROM
    "PATENTS_GOOGLE"."PATENTS_GOOGLE"."PUBLICATIONS"
),

crossover AS (
  SELECT
    "publication_number",
    "family_id"
  FROM
    "PATENTS_GOOGLE"."PATENTS_GOOGLE"."PUBLICATIONS"
),

pub AS (
  SELECT
    "family_id",
    MIN("publication_date") AS "publication_date",
    LISTAGG("publication_number", ',') WITHIN GROUP (ORDER BY "publication_number") AS "publication_number",
    LISTAGG("country_code", ',') WITHIN GROUP (ORDER BY "country_code") AS "country_code"
  FROM
    "PATENTS_GOOGLE"."PATENTS_GOOGLE"."PUBLICATIONS" AS p
  GROUP BY
    "family_id"
),

tech_class AS (
  SELECT
    p."family_id",
    LISTAGG(DISTINCT cpc.value:"code"::STRING, ',') WITHIN GROUP (ORDER BY cpc.value:"code"::STRING) AS "cpc",
    LISTAGG(DISTINCT ipc.value:"code"::STRING, ',') WITHIN GROUP (ORDER BY ipc.value:"code"::STRING) AS "ipc"
  FROM
    "PATENTS_GOOGLE"."PATENTS_GOOGLE"."PUBLICATIONS" AS p
    CROSS JOIN LATERAL FLATTEN(input => p."cpc") AS cpc
    CROSS JOIN LATERAL FLATTEN(input => p."ipc") AS ipc
  GROUP BY
    p."family_id"
),

cit AS (
  SELECT
    p."family_id",
    LISTAGG(crossover."family_id", ',') WITHIN GROUP (ORDER BY crossover."family_id" ASC) AS "citation"
  FROM
    "PATENTS_GOOGLE"."PATENTS_GOOGLE"."PUBLICATIONS" AS p
    CROSS JOIN LATERAL FLATTEN(input => p."citation") AS citation
    LEFT JOIN
      crossover
    ON
      citation.value:"publication_number"::STRING = crossover."publication_number"
  GROUP BY
    p."family_id"
),

tmp_gpr AS (
  SELECT
    "family_id",
    LISTAGG(crossover."publication_number", ',') AS "cited_by_publication_number"
  FROM
    "PATENTS_GOOGLE"."PATENTS_GOOGLE"."ABS_AND_EMB" AS p
    CROSS JOIN LATERAL FLATTEN(input => p."cited_by") AS cited_by
    LEFT JOIN
      crossover
    ON
      cited_by.value:"publication_number"::STRING = crossover."publication_number"
  GROUP BY
    "family_id"
),

gpr AS (
  SELECT
    tmp_gpr."family_id",
    LISTAGG(crossover."family_id", ',') WITHIN GROUP (ORDER BY crossover."family_id" ASC) AS "cited_by"
  FROM
    tmp_gpr
    CROSS JOIN LATERAL FLATTEN(input => SPLIT(tmp_gpr."cited_by_publication_number", ',')) AS cited_by_publication_number
    LEFT JOIN
      crossover
    ON
      cited_by_publication_number.value::STRING = crossover."publication_number"
  GROUP BY
    tmp_gpr."family_id"
)

SELECT
  fam."family_id",
  pub."publication_date",
  pub."publication_number",
  pub."country_code",
  tech_class."cpc",
  tech_class."ipc",
  cit."citation",
  gpr."cited_by"
FROM
  fam
  LEFT JOIN pub ON fam."family_id" = pub."family_id"
  LEFT JOIN tech_class ON fam."family_id" = tech_class."family_id"
  LEFT JOIN cit ON fam."family_id" = cit."family_id"
  LEFT JOIN gpr ON fam."family_id" = gpr."family_id"
WHERE
  pub."publication_date" BETWEEN 20150101 AND 20150131;
