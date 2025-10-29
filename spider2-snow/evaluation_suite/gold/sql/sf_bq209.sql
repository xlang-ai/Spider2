WITH temp_view_2 AS (
SELECT "publication_number", "application_number", "filing_date"
FROM "PATENTS"."PATENTS"."PUBLICATIONS"
WHERE "application_kind" = 'A'
AND "grant_date" >= 20100101
AND "grant_date" <= 20101231
),
citations_parsed AS (
SELECT 
    p."publication_number" AS citing_patent,
    c.value:publication_number::STRING AS cited_patent
FROM "PATENTS"."PATENTS"."PUBLICATIONS" p,
LATERAL FLATTEN(input => p."citation") c
WHERE p."citation" IS NOT NULL
AND c.value:publication_number::STRING IS NOT NULL
AND c.value:publication_number::STRING != ''
),
temp_view_6 AS (
SELECT 
    cp.citing_patent,
    cp.cited_patent,
    tv2."application_number",
    tv2."filing_date"
FROM citations_parsed cp
INNER JOIN temp_view_2 tv2 ON cp.cited_patent = tv2."publication_number"
),
temp_view_7 AS (
SELECT 
    tv6.cited_patent,
    COUNT(DISTINCT p_citing."application_number") AS distinct_citing_applications
FROM temp_view_6 tv6
INNER JOIN "PATENTS"."PATENTS"."PUBLICATIONS" p_citing ON tv6.citing_patent = p_citing."publication_number"
WHERE p_citing."filing_date" >= tv6."filing_date"
AND p_citing."filing_date" <= tv6."filing_date" + 100000
GROUP BY tv6.cited_patent
)
SELECT COUNT(*) AS patents_with_exactly_one_citation
FROM temp_view_7
WHERE distinct_citing_applications = 1