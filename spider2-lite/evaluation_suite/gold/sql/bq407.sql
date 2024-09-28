WITH population_data AS (
  SELECT
    geo_id,
    median_age,
    total_pop
  FROM
    `bigquery-public-data.census_bureau_acs.county_2017_5yr`
  WHERE
    total_pop > 50000
),
covid_data AS (
  SELECT
    county_fips_code,
    county_name,
    state,
    SUM(confirmed_cases) AS total_cases,
    SUM(deaths) AS total_deaths
  FROM
    `bigquery-public-data.covid19_usafacts.summary`
  WHERE
    date = '2022-01-01'
    AND county_fips_code != "00000"
    AND confirmed_cases + deaths > 0
  GROUP BY
    county_fips_code, county_name, state
)
SELECT
  covid.county_name,
  covid.state,
  pop.median_age,
  pop.total_pop,
  ROUND(covid.total_cases / pop.total_pop * 100000, 2) AS confirmed_cases_per_100000,
  ROUND(covid.total_deaths / pop.total_pop * 100000, 2) AS deaths_per_100000,
  ROUND(covid.total_deaths / covid.total_cases * 100, 2) AS case_fatality_rate
FROM
  covid_data covid
JOIN
  population_data pop ON covid.county_fips_code = pop.geo_id
ORDER BY
  deaths_per_100000 DESC,
  confirmed_cases_per_100000 DESC
LIMIT 3;