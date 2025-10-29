WITH "FAMS" AS (
  SELECT
    "family_id",
    MIN("publication_date") AS "earliest_publication_date_num"
  FROM "PATENTS_GOOGLE"."PATENTS_GOOGLE"."PUBLICATIONS"
  WHERE "family_id" IS NOT NULL
  GROUP BY "family_id"
  HAVING MIN("publication_date") BETWEEN 20150101 AND 20150131
),
"FAMILY_PUBS" AS (
  SELECT
    "F"."family_id",
    "F"."earliest_publication_date_num",
    TRIM("P"."publication_number") AS "publication_number",
    TRIM("P"."country_code") AS "country_code",
    "P"."cpc" AS "cpc",
    "P"."ipc" AS "ipc",
    "P"."citation" AS "citation"
  FROM "FAMS" AS "F"
  JOIN "PATENTS_GOOGLE"."PATENTS_GOOGLE"."PUBLICATIONS" AS "P"
    ON "P"."family_id" = "F"."family_id"
),
"PUBS_AGG" AS (
  SELECT
    "family_id",
    LISTAGG(DISTINCT "publication_number", ', ') WITHIN GROUP (ORDER BY "publication_number") AS "publication_numbers"
  FROM "FAMILY_PUBS"
  GROUP BY "family_id"
),
"COUNTRIES_AGG" AS (
  SELECT
    "family_id",
    LISTAGG(DISTINCT "country_code", ', ') WITHIN GROUP (ORDER BY "country_code") AS "country_codes"
  FROM "FAMILY_PUBS"
  WHERE "country_code" IS NOT NULL AND "country_code" != ''
  GROUP BY "family_id"
),
"CPC_AGG" AS (
  SELECT
    "FP"."family_id",
    LISTAGG(DISTINCT TRIM("CPC_ITEM"."VALUE":"code"::STRING), ', ')
      WITHIN GROUP (ORDER BY TRIM("CPC_ITEM"."VALUE":"code"::STRING)) AS "cpc_codes"
  FROM "FAMILY_PUBS" AS "FP",
       LATERAL FLATTEN(INPUT => "FP"."cpc") AS "CPC_ITEM"
  WHERE "CPC_ITEM"."VALUE":"code" IS NOT NULL
    AND TRIM("CPC_ITEM"."VALUE":"code"::STRING) != ''
  GROUP BY "FP"."family_id"
),
"IPC_AGG" AS (
  SELECT
    "FP"."family_id",
    LISTAGG(DISTINCT TRIM("IPC_ITEM"."VALUE":"code"::STRING), ', ')
      WITHIN GROUP (ORDER BY TRIM("IPC_ITEM"."VALUE":"code"::STRING)) AS "ipc_codes"
  FROM "FAMILY_PUBS" AS "FP",
       LATERAL FLATTEN(INPUT => "FP"."ipc") AS "IPC_ITEM"
  WHERE "IPC_ITEM"."VALUE":"code" IS NOT NULL
    AND TRIM("IPC_ITEM"."VALUE":"code"::STRING) != ''
  GROUP BY "FP"."family_id"
),
"CITED_PUBS" AS (
  SELECT
    "FP"."family_id" AS "source_family_id",
    TRIM("CIT"."VALUE":"publication_number"::STRING) AS "cited_pubnum"
  FROM "FAMILY_PUBS" AS "FP",
       LATERAL FLATTEN(INPUT => "FP"."citation") AS "CIT"
  WHERE TRIM("CIT"."VALUE":"publication_number"::STRING) IS NOT NULL
    AND TRIM("CIT"."VALUE":"publication_number"::STRING) != ''
),
"CITED_FAMILIES" AS (
  SELECT DISTINCT
    "CP"."source_family_id",
    "P_CITED"."family_id" AS "cited_family_id"
  FROM "CITED_PUBS" AS "CP"
  JOIN "PATENTS_GOOGLE"."PATENTS_GOOGLE"."PUBLICATIONS" AS "P_CITED"
    ON TRIM("P_CITED"."publication_number") = "CP"."cited_pubnum"
  WHERE "P_CITED"."family_id" IS NOT NULL
    AND "P_CITED"."family_id" != "CP"."source_family_id"
),
"CITED_FAMILIES_AGG" AS (
  SELECT
    "source_family_id" AS "family_id",
    LISTAGG(DISTINCT "cited_family_id", ', ')
      WITHIN GROUP (ORDER BY "cited_family_id") AS "families_cited"
  FROM "CITED_FAMILIES"
  GROUP BY "source_family_id"
),
"CITING_PUBS" AS (
  SELECT
    "FP"."family_id" AS "target_family_id",
    TRIM("CB"."VALUE":"publication_number"::STRING) AS "citing_pubnum"
  FROM "FAMILY_PUBS" AS "FP"
  JOIN "PATENTS_GOOGLE"."PATENTS_GOOGLE"."ABS_AND_EMB" AS "A"
    ON "A"."publication_number" = "FP"."publication_number",
       LATERAL FLATTEN(INPUT => "A"."cited_by") AS "CB"
  WHERE TRIM("CB"."VALUE":"publication_number"::STRING) IS NOT NULL
    AND TRIM("CB"."VALUE":"publication_number"::STRING) != ''
),
"CITING_FAMILIES" AS (
  SELECT DISTINCT
    "CP"."target_family_id",
    "P_ALL"."family_id" AS "citing_family_id"
  FROM "CITING_PUBS" AS "CP"
  JOIN "PATENTS_GOOGLE"."PATENTS_GOOGLE"."PUBLICATIONS" AS "P_ALL"
    ON TRIM("P_ALL"."publication_number") = "CP"."citing_pubnum"
  WHERE "P_ALL"."family_id" IS NOT NULL
    AND "P_ALL"."family_id" != "CP"."target_family_id"
),
"CITING_FAMILIES_AGG" AS (
  SELECT
    "target_family_id" AS "family_id",
    LISTAGG(DISTINCT "citing_family_id", ', ')
      WITHIN GROUP (ORDER BY "citing_family_id") AS "families_citing"
  FROM "CITING_FAMILIES"
  GROUP BY "target_family_id"
)
SELECT
  "F"."family_id",
  TO_DATE("F"."earliest_publication_date_num"::STRING, 'YYYYMMDD') AS "earliest_publication_date",
  COALESCE("PA"."publication_numbers", '') AS "publication_numbers",
  COALESCE("CA"."country_codes", '') AS "country_codes",
  COALESCE("CC"."cpc_codes", '') AS "cpc_codes",
  COALESCE("IC"."ipc_codes", '') AS "ipc_codes",
  COALESCE("CFA"."families_cited", '') AS "families_cited",
  COALESCE("CIA"."families_citing", '') AS "families_citing"
FROM "FAMS" AS "F"
LEFT JOIN "PUBS_AGG" AS "PA" ON "PA"."family_id" = "F"."family_id"
LEFT JOIN "COUNTRIES_AGG" AS "CA" ON "CA"."family_id" = "F"."family_id"
LEFT JOIN "CPC_AGG" AS "CC" ON "CC"."family_id" = "F"."family_id"
LEFT JOIN "IPC_AGG" AS "IC" ON "IC"."family_id" = "F"."family_id"
LEFT JOIN "CITED_FAMILIES_AGG" AS "CFA" ON "CFA"."family_id" = "F"."family_id"
LEFT JOIN "CITING_FAMILIES_AGG" AS "CIA" ON "CIA"."family_id" = "F"."family_id"
ORDER BY "F"."family_id";