WITH PatentApplications AS (
    SELECT 
        ANY_VALUE(assignee_harmonized) AS assignee_harmonized,  -- Randomly sampling assignee data
        ANY_VALUE(filing_date) AS filing_date,  -- Randomly sampling filing date
        application_number  -- The unique identifier for each patent application
    FROM 
        `spider2-public-data.patents.publications` AS pubs  -- Using the patent publications dataset
    WHERE EXISTS (
        -- Checks if there is a CPC code "A61K39"
        SELECT 1 FROM UNNEST(pubs.cpc) AS c WHERE c.code LIKE "A61%"
    )
    GROUP BY 
        application_number  -- Grouping by application number to ensure unique entries
)

, AssigneeApplications AS (
    SELECT 
        COUNT(*) AS total_applications,  -- Calculating the total number of applications
        a.name AS assignee_name,  -- Name of the assignee
        CAST(FLOOR(filing_date / 10000) AS INT64) AS filing_year  -- Extracting the year from the filing date
    FROM 
        PatentApplications
    CROSS JOIN
        UNNEST(assignee_harmonized) AS a  -- Expanding the assignee_harmonized array
    GROUP BY 
        a.name, filing_year  -- Grouping by assignee and year
)

, TotalApplicationsPerAssignee AS (
    SELECT
        assignee_name,
        SUM(total_applications) AS total_applications  -- Sum of all applications per assignee
    FROM 
        AssigneeApplications
    GROUP BY 
        assignee_name
    ORDER BY 
        total_applications DESC
    LIMIT 1  -- Selecting only the assignee with the highest total applications
)

, MaxYearForTopAssignee AS (
    SELECT
        aa.assignee_name,
        aa.filing_year,
        aa.total_applications
    FROM 
        AssigneeApplications aa
    INNER JOIN
        TotalApplicationsPerAssignee tapa ON aa.assignee_name = tapa.assignee_name
    ORDER BY 
        aa.total_applications DESC
    LIMIT 1  -- Finding the year with the most applications for the top assignee
)

SELECT filing_year
FROM 
    MaxYearForTopAssignee