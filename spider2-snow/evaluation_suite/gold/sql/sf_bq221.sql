WITH patent_cpcs AS (
    SELECT
        cd."parents",
        CAST(FLOOR("filing_date" / 10000) AS INT) AS "filing_year"
    FROM (
        SELECT
            MAX("cpc") AS "cpc", MAX("filing_date") AS "filing_date"
        FROM
            PATENTS.PATENTS.PUBLICATIONS
        WHERE 
            "application_number" != ''
        GROUP BY
            "application_number"
    ) AS publications
    , LATERAL FLATTEN(INPUT => "cpc") AS cpcs
    JOIN
        PATENTS.PATENTS.CPC_DEFINITION cd ON cd."symbol" = cpcs.value:"code"
    WHERE 
        cpcs.value:"first" = TRUE
          AND "filing_date" > 0

),
yearly_counts AS (
    SELECT
        "cpc_group",
        "filing_year",
        COUNT(*) AS "cnt"
    FROM (
        SELECT
            cpc_parent.value::STRING AS "cpc_group",
            "filing_year"
        FROM patent_cpcs,
             LATERAL FLATTEN(input => patent_cpcs."parents") AS cpc_parent
    )
    GROUP BY "cpc_group", "filing_year"
),
ordered_counts AS (
    SELECT
        "cpc_group",
        "filing_year",
        "cnt",
        ROW_NUMBER() OVER (PARTITION BY "cpc_group" ORDER BY "filing_year" ASC) AS rn
    FROM yearly_counts
),
recursive_ema AS (
    -- Anchor member: first year per cpc_group
    SELECT
        "cpc_group",
        "filing_year",
        "cnt",
        "cnt" * 0.2 + 0 * 0.8 AS "ema",
        rn
    FROM ordered_counts
    WHERE rn = 1

    UNION ALL

    -- Recursive member: subsequent years
    SELECT
        oc."cpc_group",
        oc."filing_year",
        oc."cnt",
        oc."cnt" * 0.2 + re."ema" * 0.8 AS "ema",
        oc.rn
    FROM ordered_counts oc
    JOIN recursive_ema re
        ON oc."cpc_group" = re."cpc_group"
       AND oc.rn = re.rn + 1
),
max_ema AS (
    SELECT
        "cpc_group",
        "filing_year",
        "ema"
    FROM recursive_ema
),
ranked_ema AS (
    SELECT
        me."cpc_group",
        me."filing_year",
        me."ema",
        ROW_NUMBER() OVER (
            PARTITION BY me."cpc_group" 
            ORDER BY me."ema" DESC, me."filing_year" DESC
        ) AS rn_rank
    FROM max_ema me
)
SELECT 
    c."titleFull",
    REPLACE(r."cpc_group", '"', '') AS "cpc_group",
    r."filing_year" AS "best_filing_year"
FROM ranked_ema r
JOIN "PATENTS"."PATENTS"."CPC_DEFINITION" c 
    ON r."cpc_group" = c."symbol"
WHERE 
    c."level" = 5
    AND r.rn_rank = 1
ORDER BY 
    c."titleFull", 
    "cpc_group" ASC;
