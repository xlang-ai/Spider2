WITH median_income_diff_by_tract AS (
  WITH acs_2018 AS (
    SELECT
      geo_id,
      median_income AS median_income_2018
    FROM
      bigquery-public-data.census_bureau_acs.censustract_2018_5yr
  ),
  acs_2015 AS (
    SELECT
      geo_id,
      median_income AS median_income_2015
    FROM
      bigquery-public-data.census_bureau_acs.censustract_2015_5yr
  ),
  acs_diff AS (
    SELECT
      a18.geo_id,
      (a18.median_income_2018 - a15.median_income_2015) AS median_income_diff
    FROM
      acs_2018 a18
    JOIN
      acs_2015 a15 ON a18.geo_id = a15.geo_id
  )
  SELECT
    *
  FROM
    acs_diff
  WHERE
    median_income_diff IS NOT NULL
)

SELECT
  sf.postal_code AS state,
  SUM(i.median_income_diff) AS total_median_income_diff,
  SUM(
    CASE
      WHEN unemployed_pop + not_in_labor_force - group_quarters < 0 THEN 0
      ELSE unemployed_pop + not_in_labor_force - group_quarters
    END
  ) AS total_not_in_labor_force,
  SUM(
    CASE
      WHEN SAFE_DIVIDE(unemployed_pop + not_in_labor_force - group_quarters, total_pop) < 0 THEN 0
      ELSE SAFE_DIVIDE(unemployed_pop + not_in_labor_force - group_quarters, total_pop)
    END
  ) / COUNT(*) AS percent_not_in_labor_force
FROM
  bigquery-public-data.census_bureau_acs.censustract_2017_5yr AS census
JOIN
  median_income_diff_by_tract i ON CAST(census.geo_id AS STRING) = i.geo_id
JOIN
  spider2-public-data.cyclistic.state_fips sf ON census.geo_id LIKE CONCAT(sf.fips, "%")
GROUP BY
  state
ORDER BY
  total_not_in_labor_force ASC
LIMIT 3;