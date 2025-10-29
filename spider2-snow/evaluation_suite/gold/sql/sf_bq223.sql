/*
Main Question: Identify non-DENSO assignees that have cited patents assigned to DENSO CORP (with valid filing dates) and list the CPC subclass titles (from the first CPC code) together with the count of such citing patents.

High-level approach
1. "denso_pubs" – all publications whose assignee list contains any form of “DENSO” *and* have a non-NULL filing date.
2. "citing_pubs" – all publications that cite at least one patent in "denso_pubs" and themselves have a non-NULL filing date.
3. "citing_infos" – for every publication in "citing_pubs":
      • flatten assignees and keep only those **not** containing “denso”;
      • take the first CPC code (cpc.value:first = TRUE) and reduce it to its 4-character subclass symbol.
   Each row now represents     (citing_pub , clean_assignee_name , cpc_subclass_symbol).
4. Join to PATENTS.PATENTS.CPC_DEFINITION to obtain the full subclass title and aggregate.
   We count DISTINCT citing publications to avoid double-counting the same patent when it cites multiple DENSO patents.
*/

WITH "denso_pubs" AS (
    /* Patents assigned to DENSO (any variant in the name) with a valid filing date */
    SELECT DISTINCT "p"."publication_number" AS "denso_pub"
    FROM "PATENTS"."PATENTS"."PUBLICATIONS" "p",
         LATERAL FLATTEN(input => "p"."assignee_harmonized") "ah"
    WHERE "p"."filing_date" IS NOT NULL
      AND UPPER("ah".value:"name"::string) LIKE '%DENSO%'
),
"citing_pubs" AS (
    /* Publications that cite any of the DENSO patents and also have a valid filing date */
    SELECT DISTINCT "cp"."publication_number" AS "citing_pub"
    FROM "PATENTS"."PATENTS"."PUBLICATIONS" "cp",
         LATERAL FLATTEN(input => "cp"."citation") "cite"
         JOIN "denso_pubs" "d"
           ON "cite".value:"publication_number"::string = "d"."denso_pub"
    WHERE "cp"."filing_date" IS NOT NULL
),
"citing_infos" AS (
    /* Extract non-DENSO assignee name and first CPC subclass for each citing publication */
    SELECT DISTINCT
           "cp"."citing_pub",
           TRIM(LOWER("ass".value:"name"::string))            AS "assignee_name",
           SUBSTR("cpc".value:"code"::string , 1 , 4)         AS "cpc_subclass_symbol"
    FROM "citing_pubs" "cp"
         JOIN "PATENTS"."PATENTS"."PUBLICATIONS" "pub"
           ON "pub"."publication_number" = "cp"."citing_pub"
         , LATERAL FLATTEN(input => "pub"."assignee_harmonized") "ass"
         , LATERAL FLATTEN(input => "pub"."cpc") "cpc"
    WHERE "ass".value:"name" IS NOT NULL
      AND LOWER("ass".value:"name"::string) NOT LIKE '%denso%'
      AND "cpc".value:"first"::boolean = TRUE
)
/* Final aggregation: count distinct citing publications per (assignee , CPC subclass title) */
SELECT
       "ci"."assignee_name"                AS "citing_assignee",
       "cd"."titleFull"                    AS "cpc_subclass_title",
       COUNT(DISTINCT "ci"."citing_pub")   AS "citation_count"
FROM "citing_infos" "ci"
     JOIN "PATENTS"."PATENTS"."CPC_DEFINITION" "cd"
       ON "cd"."symbol" = "ci"."cpc_subclass_symbol"
GROUP BY
       "ci"."assignee_name",
       "cd"."titleFull"
ORDER BY
       "citation_count" DESC,
       "citing_assignee",
       "cpc_subclass_title";