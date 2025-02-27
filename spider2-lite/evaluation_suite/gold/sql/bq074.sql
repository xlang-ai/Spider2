WITH acs_2018 AS (
  SELECT geo_id, unemployed_pop AS unemployed_2018  
  FROM `bigquery-public-data.census_bureau_acs.county_2018_5yr` 
),
 
acs_2015 AS (
  SELECT geo_id, unemployed_pop AS unemployed_2015  
  FROM `bigquery-public-data.census_bureau_acs.county_2015_5yr` 
),
 
unemployed_change AS (
  SELECT
    u18.unemployed_2018, u18.geo_id, u15.unemployed_2015,
    (u18.unemployed_2018 - u15.unemployed_2015) AS u_change
  FROM acs_2018 u18
  JOIN acs_2015 u15
  ON u18.geo_id = u15.geo_id
),
 
duals_Jan_2018 AS (
  SELECT Public_Total AS duals_2018, County_Name, FIPS 
  FROM `bigquery-public-data.sdoh_cms_dual_eligible_enrollment.dual_eligible_enrollment_by_county_and_program` 
  WHERE Date = '2018-12-01'
),

duals_Jan_2015 AS (
  SELECT Public_Total AS duals_2015, County_Name, FIPS
  FROM `bigquery-public-data.sdoh_cms_dual_eligible_enrollment.dual_eligible_enrollment_by_county_and_program` 
  WHERE Date = '2015-12-01'
),

duals_change AS (
  SELECT
    d18.FIPS, d18.County_Name, d18.duals_2018, d15.duals_2015,
    (d18.duals_2018 - d15.duals_2015) AS total_duals_diff
  FROM duals_Jan_2018 d18
  JOIN duals_Jan_2015 d15
  ON d18.FIPS = d15.FIPS
),
 
corr_tbl AS (
  SELECT unemployed_change.geo_id, duals_change.County_Name, unemployed_change.u_change, duals_change.total_duals_diff
  FROM unemployed_change
  JOIN duals_change
  ON unemployed_change.geo_id = duals_change.FIPS
)


SELECT COUNT(*)
FROM corr_tbl
WHERE
u_change >0
AND
corr_tbl.total_duals_diff < 0