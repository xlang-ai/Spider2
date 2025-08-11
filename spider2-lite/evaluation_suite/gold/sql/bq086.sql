WITH
  country_pop AS (
  SELECT
    country_code AS iso_3166_1_alpha_3,
    year_2018 AS population_2018
  FROM
    `bigquery-public-data.world_bank_global_population.population_by_country`)
SELECT
  country_code,
  country_name,
  cumulative_confirmed AS june_confirmed_cases,
  population_2018,
  ROUND(cumulative_confirmed/population_2018 * 100,2) AS case_percent
FROM
  `bigquery-public-data.covid19_open_data.covid19_open_data`
JOIN
  country_pop
USING
  (iso_3166_1_alpha_3)
WHERE
  date = '2020-06-30'
  AND aggregation_level = 0
ORDER BY
  case_percent DESC