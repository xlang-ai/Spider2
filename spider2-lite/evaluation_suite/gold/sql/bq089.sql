WITH
  num_vaccine_sites_per_county AS (
  SELECT
    facility_sub_region_1 AS us_state,
    facility_sub_region_2 AS us_county,
    facility_sub_region_2_code AS us_county_fips,
    COUNT(DISTINCT facility_place_id) AS num_vaccine_sites
  FROM
    bigquery-public-data.covid19_vaccination_access.facility_boundary_us_all
  WHERE
    STARTS_WITH(facility_sub_region_2_code, "06")
  GROUP BY
    facility_sub_region_1,
    facility_sub_region_2,
    facility_sub_region_2_code ),
  total_population_per_county AS (
  SELECT
    LEFT(geo_id, 5) AS us_county_fips,
    ROUND(SUM(total_pop)) AS total_population
  FROM
    bigquery-public-data.census_bureau_acs.censustract_2018_5yr
  WHERE
    STARTS_WITH(LEFT(geo_id, 5), "06")
  GROUP BY
    LEFT(geo_id, 5) )
SELECT
  * EXCEPT(us_county_fips),
  ROUND((num_vaccine_sites * 1000) / total_population, 2) AS sites_per_1k_ppl
FROM
  num_vaccine_sites_per_county
INNER JOIN
  total_population_per_county
USING
  (us_county_fips)
ORDER BY
  sites_per_1k_ppl ASC
LIMIT
  100;