SELECT
  aq.city,
  epa.arithmetic_mean,
  aq.value,
  aq.timestamp,
  (epa.arithmetic_mean - aq.value)
FROM
  `bigquery-public-data.openaq.global_air_quality` AS aq
JOIN
  `bigquery-public-data.epa_historical_air_quality.air_quality_annual_summary` AS epa
ON
  ROUND(aq.latitude, 2) = ROUND(epa.latitude, 2)
  AND ROUND(aq.longitude, 2) = ROUND(epa.longitude, 2)
WHERE
  epa.units_of_measure = "Micrograms/cubic meter (LC)"
  AND epa.parameter_name = "Acceptable PM2.5 AQI & Speciation Mass"
  AND epa.year = 1990
  AND aq.pollutant = "pm25"
  AND EXTRACT(YEAR FROM aq.timestamp) = 2020
ORDER BY
  (epa.arithmetic_mean - aq.value) DESC
LIMIT 3



