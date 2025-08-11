WITH acs_2018 AS (
    SELECT
      geo_id,
      median_income AS median_income_2018
    FROM
      `bigquery-public-data.census_bureau_acs.censustract_2018_5yr` 
),
acs_2015 AS (
    SELECT
      geo_id,
      median_income AS median_income_2015
    FROM
      `bigquery-public-data.census_bureau_acs.censustract_2015_5yr` ),
acs_diff AS (
    SELECT
      a18.geo_id,
      a18.median_income_2018,
      a15.median_income_2015,
      (a18.median_income_2018 - a15.median_income_2015) AS median_income_diff,
    FROM
      acs_2018 a18
    JOIN
      acs_2015 a15
    ON
      a18.geo_id = a15.geo_id
),
max_geo_id AS (
    SELECT
      geo_id
    FROM
      acs_diff
    WHERE
      median_income_diff IS NOT NULL
      AND acs_diff.geo_id in (
        SELECT
          geo_id
        FROM
          `bigquery-public-data.geo_census_tracts.census_tracts_california`
      )
    ORDER BY
      median_income_diff DESC
    LIMIT 1
)
SELECT
    tracts.tract_ce as tract_code
FROM
    max_geo_id
JOIN
    `bigquery-public-data.geo_census_tracts.census_tracts_california` AS tracts
ON
    max_geo_id.geo_id = tracts.geo_id;