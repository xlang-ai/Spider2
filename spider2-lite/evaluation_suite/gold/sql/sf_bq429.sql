WITH median_income_diff_by_zipcode AS (
  WITH acs_2018 AS (
    SELECT
      "geo_id",
      "median_income" AS "median_income_2018"
    FROM
      CENSUS_BUREAU_ACS_2.CENSUS_BUREAU_ACS."ZIP_CODES_2018_5YR"
  ),
  acs_2015 AS (
    SELECT
      "geo_id",
      "median_income" AS "median_income_2015"
    FROM
      CENSUS_BUREAU_ACS_2.CENSUS_BUREAU_ACS."ZIP_CODES_2015_5YR"
  ),
  acs_diff AS (
    SELECT
      a18."geo_id",
      (a18."median_income_2018" - a15."median_income_2015") AS "median_income_diff"
    FROM
      acs_2018 a18
    JOIN
      acs_2015 a15 ON a18."geo_id" = a15."geo_id"
  )
  SELECT
    "geo_id",
    AVG("median_income_diff") AS "avg_median_income_diff"
  FROM
    acs_diff
  WHERE
    "median_income_diff" IS NOT NULL
  GROUP BY "geo_id"
),
base_census AS (
  SELECT
    geo."state_name",
    AVG(i."avg_median_income_diff") AS "avg_median_income_diff",
    AVG(
      "employed_wholesale_trade" * 0.38423645320197042 +
      "occupation_natural_resources_construction_maintenance" * 0.48071410777129553 +
      "employed_arts_entertainment_recreation_accommodation_food" * 0.89455676291236841 +
      "employed_information" * 0.31315240083507306 +
      "employed_retail_trade" * 0.51
    ) AS "avg_vulnerable"
  FROM
    CENSUS_BUREAU_ACS_2.CENSUS_BUREAU_ACS."ZIP_CODES_2017_5YR" AS census
  JOIN
    median_income_diff_by_zipcode i ON CAST(census."geo_id" AS STRING) = i."geo_id"
  JOIN
    CENSUS_BUREAU_ACS_2.GEO_US_BOUNDARIES."ZIP_CODES" geo ON census."geo_id" = geo."zip_code"
  GROUP BY geo."state_name"
)

SELECT 
  "state_name",
  "avg_median_income_diff",
  "avg_vulnerable"
FROM 
  base_census
ORDER BY 
  "avg_median_income_diff" DESC
LIMIT 5;
