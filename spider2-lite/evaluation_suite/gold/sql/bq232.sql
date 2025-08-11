WITH borough_data AS (
    SELECT 
        year, 
        month, 
        borough, 
        major_category, 
        minor_category, 
        SUM(value) AS total,
    CASE 
        WHEN 
            major_category = 'Theft and Handling' 
        THEN 
            'Theft and Handling'
        ELSE 
            'Other' 
    END AS major_division,
    CASE 
        WHEN 
            minor_category = 'Other Theft' THEN minor_category
        ELSE 
            'Other'
    END AS minor_division,
    FROM 
        bigquery-public-data.london_crime.crime_by_lsoa
    GROUP BY 1,2,3,4,5
    ORDER BY 1,2
)

SELECT year, SUM(total) AS year_total
FROM borough_data
WHERE 
    borough = 'Westminster'
AND
    major_division != 'Other'
AND 
    minor_division != 'Other'
GROUP BY year, major_division, minor_division
ORDER BY year;