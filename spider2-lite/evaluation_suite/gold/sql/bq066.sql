WITH poverty_and_natality AS (
  SELECT
    EXTRACT(YEAR FROM n.Year) AS data_year,
    p.geo_id AS county_fips,
    (p.poverty / p.pop_determined_poverty_status) * 100 AS poverty_rate,
    SUM(n.Births) AS total_births,
    SUM(CASE WHEN n.Maternal_Morbidity_YN = 0 THEN n.Births ELSE 0 END) AS births_without_morbidity
  FROM
    `bigquery-public-data.census_bureau_acs.county_2015_5yr` p
  JOIN
    `bigquery-public-data.sdoh_cdc_wonder_natality.county_natality_by_maternal_morbidity` n
  ON p.geo_id = n.County_of_Residence_FIPS
  WHERE
    p.pop_determined_poverty_status > 0 AND
    EXTRACT(YEAR FROM n.Year) = 2016
  GROUP BY
    p.geo_id, p.poverty, p.pop_determined_poverty_status, EXTRACT(YEAR FROM n.Year)
  UNION ALL
  SELECT
    EXTRACT(YEAR FROM n.Year) AS data_year,
    p.geo_id AS county_fips,
    (p.poverty / p.pop_determined_poverty_status) * 100 AS poverty_rate,
    SUM(n.Births) AS total_births,
    SUM(CASE WHEN n.Maternal_Morbidity_YN = 0 THEN n.Births ELSE 0 END) AS births_without_morbidity
  FROM
    `bigquery-public-data.census_bureau_acs.county_2016_5yr` p
  JOIN
    `bigquery-public-data.sdoh_cdc_wonder_natality.county_natality_by_maternal_morbidity` n
  ON p.geo_id = n.County_of_Residence_FIPS
  WHERE
    p.pop_determined_poverty_status > 0 AND
    EXTRACT(YEAR FROM n.Year) = 2017
  GROUP BY
    p.geo_id, p.poverty, p.pop_determined_poverty_status, EXTRACT(YEAR FROM n.Year)
  UNION ALL
  SELECT
    EXTRACT(YEAR FROM n.Year) AS data_year,
    p.geo_id AS county_fips,
    (p.poverty / p.pop_determined_poverty_status) * 100 AS poverty_rate,
    SUM(n.Births) AS total_births,
    SUM(CASE WHEN n.Maternal_Morbidity_YN = 0 THEN n.Births ELSE 0 END) AS births_without_morbidity
  FROM
    `bigquery-public-data.census_bureau_acs.county_2017_5yr` p
  JOIN
    `bigquery-public-data.sdoh_cdc_wonder_natality.county_natality_by_maternal_morbidity` n
  ON p.geo_id = n.County_of_Residence_FIPS
  WHERE
    p.pop_determined_poverty_status > 0 AND
    EXTRACT(YEAR FROM n.Year) = 2018
  GROUP BY
    p.geo_id, p.poverty, p.pop_determined_poverty_status, EXTRACT(YEAR FROM n.Year)
)

SELECT
  data_year,
  CORR(poverty_rate, (births_without_morbidity / total_births) * 100) AS correlation_coefficient
FROM
  poverty_and_natality
GROUP BY
  data_year
