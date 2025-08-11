WITH natality_2018 AS (
  SELECT County_of_Residence_FIPS AS FIPS, Ave_Number_of_Prenatal_Wks AS Vist_Ave, County_of_Residence
  FROM `bigquery-public-data.sdoh_cdc_wonder_natality.county_natality` 
  WHERE SUBSTR(County_of_Residence_FIPS, 0, 2) = "55" AND Year = '2018-01-01'
),

acs_2017 AS (
  SELECT geo_id, commute_45_59_mins, employed_pop
  FROM `bigquery-public-data.census_bureau_acs.county_2017_5yr`
),

corr_tbl AS (
  SELECT
    n.County_of_Residence,
    ROUND((a.commute_45_59_mins / a.employed_pop) * 100, 2) AS percent_high_travel,
    n.Vist_Ave
  FROM acs_2017 a
  JOIN natality_2018 n
  ON a.geo_id = n.FIPS
)

SELECT County_of_Residence, Vist_Ave
FROM corr_tbl
WHERE percent_high_travel > 5
