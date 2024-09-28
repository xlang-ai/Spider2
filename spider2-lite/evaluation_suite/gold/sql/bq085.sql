WITH country_pop AS (
  SELECT
    CASE 
      WHEN country = "United States" THEN "US"
      WHEN country = "Iran, Islamic Rep." THEN "Iran"
      ELSE country
    END AS country,
    year_2018
  FROM
    `bigquery-public-data.world_bank_global_population.population_by_country`
)

SELECT
  cases.date AS date,
  cases.country_region AS country_region,
  SUM(cases.confirmed) AS total_confirmed_cases,
  SUM(cases.confirmed) / AVG(country_pop.year_2018) * 100000 AS confirmed_cases_per_100000
FROM
  `bigquery-public-data.covid19_jhu_csse.summary` cases
JOIN
  country_pop ON cases.country_region = country_pop.country
WHERE
  cases.country_region IN ("US", "France", "China", "Italy", "Spain", "Germany", "Iran")
  AND cases.date = '2021-04-20'
GROUP BY
  country_region, date
ORDER BY
  confirmed_cases_per_100000 DESC
