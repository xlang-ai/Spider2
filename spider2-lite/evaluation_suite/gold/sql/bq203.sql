WITH stations_n_entrances AS (
      SELECT borough_name,s.station_name,entry,ada_compliant
      FROM `bigquery-public-data.new_york_subway.stations` s
      JOIN `bigquery-public-data.new_york_subway.station_entrances` se
      ON s.station_name = se.station_name
      )

SELECT se.borough_name, COUNT(DISTINCT se.station_name) num_stations,
      COUNT(DISTINCT adas.station_name) num_stations_w_compliant_entrance, 
      (100*COUNT(DISTINCT adas.station_name))/(COUNT(DISTINCT se.station_name)) percent_compliant_stations
FROM `stations_n_entrances` se
LEFT JOIN `stations_n_entrances` adas
ON se.station_name = adas.station_name
AND adas.entry AND adas.ada_compliant
GROUP BY 1
ORDER BY 4 DESC