WITH patent_cpcs AS (
    SELECT
        cd."parents",
        CAST(FLOOR("filing_date" / 10000) AS INT) AS "filing_year"
    FROM (
        SELECT MAX("cpc") AS "cpc", MAX("filing_date") AS "filing_date"
        FROM "PATENTS"."PATENTS"."PUBLICATIONS"
        WHERE "application_number" != ''
          AND "country_code" = 'DE'
          AND "grant_date" >= 20161201
          AND "grant_date" <= 20161231
        GROUP BY "application_number"
    ), LATERAL FLATTEN(INPUT => "cpc") AS cpcs
    JOIN "PATENTS"."PATENTS"."CPC_DEFINITION" cd ON cd."symbol" = cpcs.value:"code"
    WHERE cpcs.value:"first" = TRUE
      AND "filing_date" > 0
),
yearly_counts AS (
    SELECT
        "cpc_group",
        "filing_year",
        COUNT(*) AS "cnt"
    FROM (
        SELECT
            cpc_parent.VALUE AS "cpc_group",  -- Corrected reference to flattened "parents"
            "filing_year"
        FROM patent_cpcs,
             LATERAL FLATTEN(INPUT => "parents") AS cpc_parent  -- Corrected reference to flattened "parents"
    )
    GROUP BY "cpc_group", "filing_year"
),
moving_avg AS (
    SELECT
        "cpc_group",
        "filing_year",
        "cnt",
        AVG("cnt") OVER (PARTITION BY "cpc_group" ORDER BY "filing_year" ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS "moving_avg"
    FROM yearly_counts
)
SELECT 
    c."titleFull",  -- Ensure correct column name (check case)
    REPLACE("cpc_group", '"', '') AS "cpc_group",
    MAX("filing_year") AS "best_filing_year"
FROM moving_avg
JOIN "PATENTS"."PATENTS"."CPC_DEFINITION" c ON "cpc_group" = c."symbol"
WHERE c."level" = 4
GROUP BY c."titleFull", "cpc_group"
ORDER BY c."titleFull", "cpc_group" ASC;
