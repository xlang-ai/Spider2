CREATE TEMPORARY FUNCTION highest_moving_avg(yearcnt ARRAY<STRUCT<filing_year INT64, cnt INT64>>)
RETURNS STRUCT<filing_year INT64, avg INT64>
LANGUAGE js AS """
    let a = 0.2;
    let avg = yearcnt.length > 0 ? yearcnt[0].cnt : 0;
    let highest = {filing_year: -1, avg: -1};
    for (let x of yearcnt) {
        avg = a * x.cnt + (1 - a) * avg;
        if (avg > highest.avg) {
                highest = {filing_year: x.filing_year, avg: avg};
        }
    }
    return highest;
""";
    
WITH patent_cpcs AS (
    SELECT
        cd.parents,
        CAST(FLOOR(filing_date/10000) AS INT64) AS filing_year
    FROM (
        SELECT
            ANY_VALUE(cpc) AS cpc,
            ANY_VALUE(filing_date) AS filing_date
        FROM
            `patents-public-data.patents.publications`
        WHERE 
            application_number != ""
        GROUP BY
            application_number
        ), UNNEST(cpc) AS cpcs
    JOIN
        `patents-public-data.cpc.definition` cd
    ON cd.symbol = cpcs.code
    WHERE
        cpcs.first = TRUE
        AND filing_date > 0
)

SELECT c.titleFull, cpc_group, best_year.filing_year
FROM (
    SELECT
        cpc_group,
        highest_moving_avg(ARRAY_AGG(STRUCT<filing_year INT64, cnt INT64>(filing_year, cnt) ORDER BY filing_year ASC)) AS best_year
    FROM (
        SELECT
            cpc_group,
            filing_year,
            COUNT(*) AS cnt
        FROM (
            SELECT
                cpc_parent AS cpc_group,
                filing_year
            FROM
                patent_cpcs,
                UNNEST(parents) AS cpc_parent
        )
        GROUP BY cpc_group, filing_year
        ORDER BY filing_year DESC, cnt DESC
    )
    GROUP BY cpc_group
)
JOIN `patents-public-data.cpc.definition` c
ON cpc_group = c.symbol
WHERE c.level = 5
ORDER BY c.titleFull, cpc_group ASC;