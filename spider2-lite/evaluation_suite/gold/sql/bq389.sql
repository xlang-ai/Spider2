SELECT
  pm10.month AS month,
  pm10.avg AS pm10,
  pm25_frm.avg AS pm25_frm,
  pm25_nonfrm.avg AS pm25_nonfrm,
  co.avg AS co,
  so2.avg AS so2,
  lead.avg AS lead
FROM
  (SELECT AVG(arithmetic_mean) AS avg, 
          EXTRACT(YEAR FROM date_local) AS year, 
          EXTRACT(MONTH FROM date_local) AS month
   FROM `bigquery-public-data.epa_historical_air_quality.pm10_daily_summary`
   WHERE state_name = 'California' AND EXTRACT(YEAR FROM date_local) = 2020
   GROUP BY year, month) AS pm10
JOIN
  (SELECT AVG(arithmetic_mean) AS avg, 
          EXTRACT(YEAR FROM date_local) AS year, 
          EXTRACT(MONTH FROM date_local) AS month
   FROM `bigquery-public-data.epa_historical_air_quality.pm25_frm_daily_summary`
   WHERE state_name = 'California' AND EXTRACT(YEAR FROM date_local) = 2020
   GROUP BY year, month) AS pm25_frm
ON pm10.year = pm25_frm.year AND pm10.month = pm25_frm.month
JOIN
  (SELECT AVG(arithmetic_mean) AS avg, 
          EXTRACT(YEAR FROM date_local) AS year, 
          EXTRACT(MONTH FROM date_local) AS month
   FROM `bigquery-public-data.epa_historical_air_quality.pm25_nonfrm_daily_summary`
   WHERE state_name = 'California' AND EXTRACT(YEAR FROM date_local) = 2020
   GROUP BY year, month) AS pm25_nonfrm
ON pm10.year = pm25_nonfrm.year AND pm10.month = pm25_nonfrm.month
JOIN
  (SELECT AVG(arithmetic_mean) * 100 AS avg, 
          EXTRACT(YEAR FROM date_local) AS year, 
          EXTRACT(MONTH FROM date_local) AS month
   FROM `bigquery-public-data.epa_historical_air_quality.lead_daily_summary`
   WHERE state_name = 'California' AND EXTRACT(YEAR FROM date_local) = 2020
   GROUP BY year, month) AS lead
ON pm10.year = lead.year AND pm10.month = lead.month
JOIN
  (SELECT AVG(arithmetic_mean) AS avg, 
          EXTRACT(YEAR FROM date_local) AS year, 
          EXTRACT(MONTH FROM date_local) AS month
   FROM `bigquery-public-data.epa_historical_air_quality.voc_daily_summary`
   WHERE state_name = 'California' AND EXTRACT(YEAR FROM date_local) = 2020
   GROUP BY year, month) AS co
ON pm10.year = co.year AND pm10.month = co.month
JOIN
  (SELECT AVG(arithmetic_mean) * 10 AS avg, 
          EXTRACT(YEAR FROM date_local) AS year, 
          EXTRACT(MONTH FROM date_local) AS month
   FROM `bigquery-public-data.epa_historical_air_quality.so2_daily_summary`
   WHERE state_name = 'California' AND EXTRACT(YEAR FROM date_local) = 2020
   GROUP BY year, month) AS so2
ON pm10.year = so2.year AND pm10.month = so2.month
ORDER BY
  month;