WITH acs_2017 AS (
  SELECT geo_id, income_less_10000 AS i10, income_10000_14999 AS i15, income_15000_19999 AS i20
  FROM `bigquery-public-data.census_bureau_acs.county_2017_5yr`
 ),

snap_2017_Jan AS (
  SELECT FIPS, SNAP_All_Participation_Households AS snap_total
  FROM `bigquery-public-data.sdoh_snap_enrollment.snap_enrollment`
  WHERE Date = '2017-01-01'
)

SELECT acs_2017.geo_id, snap_2017_Jan.snap_total,
(acs_2017.i10 + acs_2017.i15 + acs_2017.i20) As households_under_20,
(acs_2017.i10 + acs_2017.i15 + acs_2017.i20)/snap_2017_Jan.snap_total As under_20_snap_ratio 
FROM acs_2017
JOIN snap_2017_Jan
ON  acs_2017.geo_id = snap_2017_Jan.FIPS
WHERE snap_2017_Jan.snap_total > 0
ORDER BY snap_2017_Jan.snap_total DESC
LIMIT 10
