SELECT
  COUNT(a.consecutive_number) AS total,
  a.state_name AS state,
  c.state_pop AS population,
  ROUND((COUNT(a.consecutive_number) / c.state_pop) * 100000, 3) AS rate_per_100000
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
    d.zipcode=e.zipcode
  GROUP BY
    state ) c
ON
  c.state=a.state_name
WHERE
  b.driver_distracted_by_name != 'Not Distracted'
  AND b.driver_distracted_by_name != 'Unknown if Distracted'
  AND b.driver_distracted_by_name != 'Not Reported'
GROUP BY
  state,
  population,
  c.state_pop
ORDER BY
  rate_per_100000 DESC;
