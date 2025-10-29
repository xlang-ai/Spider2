WITH december_2016_grants AS (
    SELECT DISTINCT 
        SUBSTRING(f.value:"code"::STRING, 1, 4) AS cpc_level4
    FROM "PATENTS"."PATENTS"."PUBLICATIONS" p,
    LATERAL FLATTEN(input => p."cpc") f
    WHERE p."country_code" = 'DE' 
    AND p."grant_date" >= 20161201 
    AND p."grant_date" <= 20161231
),
all_german_patents AS (
    SELECT 
        "publication_number",
        "filing_date",
        FLOOR("filing_date" / 10000) AS filing_year,
        f.value:"code"::STRING AS cpc_code,
        SUBSTRING(cpc_code, 1, 4) AS cpc_level4
    FROM "PATENTS"."PATENTS"."PUBLICATIONS" p,
    LATERAL FLATTEN(input => p."cpc") f
    WHERE p."country_code" = 'DE' 
    AND p."filing_date" IS NOT NULL
    AND p."filing_date" > 0
    AND cpc_level4 IN (SELECT cpc_level4 FROM december_2016_grants)
),
yearly_counts AS (
    SELECT 
        cpc_level4,
        filing_year,
        COUNT(DISTINCT "publication_number") AS patent_count
    FROM all_german_patents
    WHERE filing_year > 0
    GROUP BY cpc_level4, filing_year
),
ordered_counts AS (
    SELECT 
        cpc_level4,
        filing_year,
        patent_count,
        ROW_NUMBER() OVER (PARTITION BY cpc_level4 ORDER BY filing_year) AS year_rank
    FROM yearly_counts
),
ema_calculated AS (
    SELECT 
        cpc_level4,
        filing_year,
        patent_count,
        patent_count AS ema,
        year_rank
    FROM ordered_counts
    WHERE year_rank = 1
    
    UNION ALL
    
    SELECT 
        oc.cpc_level4,
        oc.filing_year,
        oc.patent_count,
        ROUND(0.1 * oc.patent_count + 0.9 * ec.ema, 2) AS ema,
        oc.year_rank
    FROM ordered_counts oc
    JOIN ema_calculated ec ON oc.cpc_level4 = ec.cpc_level4 AND oc.year_rank = ec.year_rank + 1
),
max_ema_per_cpc AS (
    SELECT 
        cpc_level4,
        filing_year,
        ema,
        ROW_NUMBER() OVER (PARTITION BY cpc_level4 ORDER BY ema DESC, filing_year DESC) as ema_rank
    FROM ema_calculated
)
SELECT 
    m.cpc_level4 AS cpc_group,
    cd."titleFull" AS full_title,
    m.filing_year AS year,
    m.ema AS highest_exponential_moving_average
FROM max_ema_per_cpc m
LEFT JOIN "PATENTS"."PATENTS"."CPC_DEFINITION" cd 
    ON m.cpc_level4 = cd."symbol"
WHERE m.ema_rank = 1
ORDER BY m.ema DESC