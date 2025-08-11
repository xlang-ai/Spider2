SELECT
  c.country,
  c.total_confirmed_cases,
  (c.total_confirmed_cases / p.population) * 100000 AS cases_per_100k
FROM
  (
    SELECT
      CASE
        WHEN country_region = 'US' THEN 'United States'
        WHEN country_region = 'Iran' THEN 'Iran, Islamic Rep.'
        ELSE country_region
      END AS country,
      SUM(confirmed) AS total_confirmed_cases
    FROM
      `bigquery-public-data.covid19_jhu_csse.summary`
    WHERE
      date = '2020-04-20'
      AND country_region IN ('US', 'France', 'China', 'Italy', 'Spain', 'Germany', 'Iran')
    GROUP BY
      country
  ) AS c
JOIN
  (
    SELECT
      country_name AS country,
      SUM(value) AS population
    FROM
      `bigquery-public-data.world_bank_wdi.indicators_data`
    WHERE
      indicator_code = 'SP.POP.TOTL'
      AND year = 2020
    GROUP BY
      country_name
  ) AS p
ON
  c.country = p.country
ORDER BY
  cases_per_100k DESC