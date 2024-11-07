WITH PatentApplications AS (
    SELECT 
        ANY_VALUE(assignee_harmonized) AS assignee_harmonized,  -- Collects any sample of harmonized assignee data.
        ANY_VALUE(filing_date) AS filing_date,  -- Collects any sample of filing date.
        ANY_VALUE(country_code) AS country_code,  -- Collects any sample of country code.
        application_number  -- The unique identifier for each patent application.
    FROM 
        `patents-public-data.patents.publications` AS pubs  -- Using the patents publications dataset.
    WHERE EXISTS (
        SELECT 1 FROM UNNEST(pubs.cpc) AS c WHERE REGEXP_CONTAINS(c.code, "A01B3")
    )
    GROUP BY 
        application_number  -- Group by application number to ensure distinct entries.
)

,AssigneeApplications AS (
    SELECT 
        COUNT(*) AS year_country_cnt,  -- Count of applications per assignee, year, and country.
        a.name AS assignee_name,  -- Name of the assignee.
        CAST(FLOOR(filing_date / 10000) AS INT64) AS filing_year,  -- Extracts the year from the filing date.
        apps.country_code  -- Country code of the application.
    FROM 
        PatentApplications AS apps  -- Using the previously defined CTE.
    CROSS JOIN
    UNNEST(assignee_harmonized) AS a  -- Expanding the assignee_harmonized array.
    GROUP BY 
        a.name, filing_year, country_code  -- Grouping by assignee, year, and country.
)

-- CTE to aggregate data by assignee and year and to collect top 5 countries by application count.
,AggregatedData AS (
    SELECT 
        SUM(year_country_cnt) AS year_cnt,  -- Sum of all applications per assignee per year.
        assignee_name, 
        filing_year, 
        -- Aggregates the top 5 countries by their application counts in descending order.
        STRING_AGG(country_code ORDER BY year_country_cnt DESC LIMIT 1) AS countries
    FROM 
        AssigneeApplications  -- Using the AssigneeApplications CTE.
    GROUP BY 
        assignee_name, filing_year  -- Grouping results by assignee and year.
)

-- Final aggregation to find the year with the highest application count for each assignee.
,FinalAggregation AS (
    SELECT 
        SUM(year_cnt) AS total_count,  -- Total count of applications for each assignee.
        assignee_name,
        -- Aggregates into a structure the year and countries data with the highest application count.
        ARRAY_AGG(
            STRUCT<cnt INT64, filing_year INT64, countries STRING>
            (year_cnt, filing_year, countries) 
            ORDER BY year_cnt DESC LIMIT 1
        )[SAFE_ORDINAL(1)] AS largest_year  -- Selects the year with the highest application count.
    FROM 
        AggregatedData  -- Using the AggregatedData CTE.
    GROUP BY 
        assignee_name  -- Grouping by assignee.
)

-- Selecting final results including total application count, assignee name, and details of their largest year.
SELECT 
    total_count,
    assignee_name,
    largest_year.cnt,
    largest_year.filing_year,
    largest_year.countries
FROM 
    FinalAggregation  -- Using the FinalAggregation CTE.
ORDER BY 
    total_count DESC  -- Ordering by total application count in descending order.
LIMIT 20;  -- Limits the results to the top 20 assignees.