WITH geo AS (
  SELECT DISTINCT geo_id
  FROM `bigquery-public-data.geo_us_boundaries.counties`
  WHERE county_name = "Allegheny" 
),
avg_wage_1998 AS(
  SELECT
    ROUND(AVG(avg_wkly_wage_10_total_all_industries) * 52, 2) AS wages_1998
  FROM
    `bigquery-public-data.bls_qcew.1998*`
  WHERE
    geoid = (SELECT geo_id FROM geo) --Selecting Allgeheny County
),
    
avg_wage_2017 AS (
  SELECT
    ROUND(AVG(avg_wkly_wage_10_total_all_industries) * 52, 2) AS wages_2017
  FROM
    `bigquery-public-data.bls_qcew.2017*`
  WHERE
    geoid = (SELECT geo_id FROM geo) --Selecting Allgeheny County
),

avg_cpi_1998 AS (
  SELECT
    AVG(value) AS cpi_1998
  FROM
    `bigquery-public-data.bls.cpi_u` c
  WHERE
    year = 1998
    AND item_code in (
      SELECT DISTINCT item_code FROM `bigquery-public-data.bls.cpi_u` WHERE LOWER(item_name) = "all items"
    )
    AND area_code = (
      SELECT DISTINCT area_code FROM `bigquery-public-data.bls.cpi_u` WHERE area_name LIKE '%Pittsburgh%'
    )
), 
-- A104 is the code for Pittsburgh, PA
-- SA0 is the code for all items
    
avg_cpi_2017 AS(
  SELECT
    AVG(value) AS cpi_2017
  FROM
    `bigquery-public-data.bls.cpi_u` c
  WHERE
    year = 2017
    AND item_code in (
      SELECT DISTINCT item_code FROM `bigquery-public-data.bls.cpi_u` WHERE LOWER(item_name) = "all items"
    )
    AND area_code = (
      SELECT DISTINCT area_code FROM `bigquery-public-data.bls.cpi_u` WHERE area_name LIKE '%Pittsburgh%'
    )
)
-- A104 is the code for Pittsburgh, PA
-- SA0 is the code for all items

SELECT
  ROUND((wages_2017 - wages_1998) / wages_1998 * 100, 2) AS wages_percent_change,
  ROUND((cpi_2017 - cpi_1998) / cpi_1998 * 100, 2) AS cpi_percent_change
FROM
  avg_wage_2017,
  avg_wage_1998,
  avg_cpi_2017,
  avg_cpi_1998