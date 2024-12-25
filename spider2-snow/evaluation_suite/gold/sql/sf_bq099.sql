WITH PatentApplications AS (
   SELECT 
        "assignee_harmonized" AS assignee_harmonized,
        "filing_date" AS filing_date,
        "country_code" AS country_code,
        "application_number" AS application_number
    FROM 
        PATENTS.PATENTS.PUBLICATIONS AS pubs,
        LATERAL FLATTEN(input => pubs."cpc") AS c
    WHERE c.value:"code" LIKE 'A01B3%'

),

AssigneeApplications AS (
    SELECT 
        COUNT(*) AS year_country_cnt,
        a.value:"name" AS assignee_name,
        CAST(FLOOR(filing_date / 10000) AS INT) AS filing_year,
        apps.country_code as country_code
    FROM 
        PatentApplications as apps,
        LATERAL FLATTEN(input => assignee_harmonized) AS a
    GROUP BY 
        assignee_name, filing_year, country_code
),

RankedApplications AS (
    SELECT
        assignee_name,
        filing_year,
        country_code,
        year_country_cnt,
        SUM(year_country_cnt) OVER (PARTITION BY assignee_name, filing_year) AS total_cnt,
        ROW_NUMBER() OVER (PARTITION BY assignee_name, filing_year ORDER BY year_country_cnt DESC) AS rn
    FROM
        AssigneeApplications
),

AggregatedData AS (
    SELECT
        total_cnt AS year_cnt,
        assignee_name,
        filing_year,
        country_code
    FROM
        RankedApplications
    WHERE
        rn = 1
)


SELECT 
    total_count,
    REPLACE(assignee_name, '"', '') AS assignee_name,
    year_cnt,
    filing_year,
    country_code
FROM (
    SELECT 
        year_cnt,
        assignee_name,
        filing_year,
        country_code,
        SUM(year_cnt) OVER (PARTITION BY assignee_name) AS total_count,
        ROW_NUMBER() OVER (PARTITION BY assignee_name ORDER BY year_cnt DESC) AS rn
    FROM
        AggregatedData
    ORDER BY assignee_name
) sub
WHERE rn = 1
ORDER BY total_count
DESC
LIMIT 3