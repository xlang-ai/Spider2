SELECT * FROM
(
SELECT
  '2015' AS year,
  COUNT(a.consecutive_number) AS total,
  a.state_name AS state,
  c.state_pop AS population,
  (COUNT(a.consecutive_number) / c.state_pop * 100000) AS rate_per_100000
FROM
  `bigquery-public-data.nhtsa_traffic_fatalities.accident_2015` a
JOIN
  `bigquery-public-data.nhtsa_traffic_fatalities.distract_2015` b
ON
  a.consecutive_number = b.consecutive_number
JOIN (
  SELECT
    SUM(d.population) AS state_pop,
    e.state_name AS state
  FROM
    `bigquery-public-data.census_bureau_usa.population_by_zip_2010` d
  JOIN
    `bigquery-public-data.utility_us.zipcode_area` e
  ON
    d.zipcode = e.zipcode
  GROUP BY
    state ) c
ON
  c.state = a.state_name
WHERE
  b.driver_distracted_by_name NOT IN ('Not Distracted', 'Unknown if Distracted', 'Not Reported')
GROUP BY
  state,
  population,
  c.state_pop
ORDER BY
  rate_per_100000 DESC
LIMIT 5
)
UNION ALL
(
SELECT
  '2016' AS year,
  COUNT(a.consecutive_number) AS total,
  a.state_name AS state,
  c.state_pop AS population,
  (COUNT(a.consecutive_number) / c.state_pop * 100000) AS rate_per_100000
FROM
  `bigquery-public-data.nhtsa_traffic_fatalities.accident_2016` a
JOIN
  `bigquery-public-data.nhtsa_traffic_fatalities.distract_2016` b
ON
  a.consecutive_number = b.consecutive_number
JOIN (
  SELECT
    SUM(d.population) AS state_pop,
    e.state_name AS state
  FROM
    `bigquery-public-data.census_bureau_usa.population_by_zip_2010` d
  JOIN
    `bigquery-public-data.utility_us.zipcode_area` e
  ON
    d.zipcode = e.zipcode
  GROUP BY
    state ) c
ON
  c.state = a.state_name
WHERE
  b.driver_distracted_by_name NOT IN ('Not Distracted', 'Unknown if Distracted', 'Not Reported')
GROUP BY
  state,
  population,
  c.state_pop
ORDER BY
  rate_per_100000 DESC
LIMIT 5
)