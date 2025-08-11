WITH all_zip_tract_join AS (
  SELECT 
    zips.zip_code, 
    zips.functional_status as zip_functional_status,
    tracts.tract_ce, 
    tracts.geo_id as tract_geo_id, 
    tracts.functional_status as tract_functional_status,
    ST_Area(ST_Intersection(tracts.tract_geom, zips.zip_code_geom))
        / ST_Area(tracts.tract_geom) as tract_pct_in_zip_code
  FROM  
    `bigquery-public-data.geo_census_tracts.us_census_tracts_national` tracts,
    `bigquery-public-data.geo_us_boundaries.zip_codes` zips
  WHERE 
    ST_Intersects(tracts.tract_geom, zips.zip_code_geom)
),
zip_tract_join AS (
  SELECT * FROM all_zip_tract_join WHERE tract_pct_in_zip_code > 0
),
census_totals AS (
  -- convert averages to additive totals
  SELECT 
    geo_id,
    total_pop,
    total_pop * income_per_capita AS total_income 
  FROM 
    `bigquery-public-data.census_bureau_acs.censustract_2017_5yr` 
),
joined AS ( 
  -- join with precomputed census/zip pairs,
  -- compute zip's share of tract
  SELECT 
    zip_code, 
    total_pop * tract_pct_in_zip_code    AS zip_pop,
    total_income * tract_pct_in_zip_code AS zip_income
  FROM census_totals c
  JOIN zip_tract_join ztj
  ON c.geo_id = ztj.tract_geo_id
),
sums AS ( 
  -- aggregate all "pieces" of zip code
  SELECT
    zip_code, 
    SUM(zip_pop) AS zip_pop,
    SUM(zip_income) AS zip_total_inc
  FROM joined 
  GROUP BY zip_code
),
zip_pop_income AS (
    SELECT 
        zip_code, zip_pop, 
        -- convert to averages
        zip_total_inc / zip_pop AS income_per_capita
    FROM sums
),
zipcodes_within_distance as (
    SELECT 
        zip_code, zip_code_geom
    FROM 
        `bigquery-public-data.geo_us_boundaries.zip_codes`
    WHERE
        state_code = 'WA'  -- Washington state code
        AND
        ST_DWithin(
            ST_GeogPoint(-122.191667, 47.685833),
            zip_code_geom,
            8046.72
        )
)
select 
  stats.zip_code,
  ROUND(stats.zip_pop, 1) as zip_population,
  ROUND(stats.income_per_capita, 1) as average_income
from 
  zipcodes_within_distance area
join 
  zip_pop_income stats
on area.zip_code = stats.zip_code
ORDER BY
    average_income DESC;