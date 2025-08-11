WITH ranked_crimes AS (
    SELECT
        borough,
        major_category,
        RANK() OVER(PARTITION BY borough ORDER BY SUM(value) DESC) AS rank_per_borough,
        SUM(value) AS no_of_incidents
    FROM
        `bigquery-public-data.london_crime.crime_by_lsoa`
    GROUP BY
        borough,
        major_category
)

SELECT
    borough,
    major_category,
    rank_per_borough,
    no_of_incidents
FROM
    ranked_crimes
WHERE
    rank_per_borough <= 3
AND 
    borough = 'Barking and Dagenham'
ORDER BY
    borough,
    rank_per_borough;