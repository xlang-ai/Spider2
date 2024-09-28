SELECT 
  -- user type
  trip.usertype,
  -- average weather information
  AVG(CAST(w.prcp AS FLOAT64)) AS avg_precipitation,  
  AVG(CAST(w.wdsp AS FLOAT64)) AS avg_wind_speed,     
  AVG(CAST(w.temp AS FLOAT64)) AS avg_temperature
FROM `bigquery-public-data.new_york_citibike.citibike_trips` trip
INNER JOIN `bigquery-public-data.geo_us_boundaries.zip_codes` zip_start
  ON ST_WITHIN(
    ST_GEOGPOINT(trip.start_station_longitude, trip.start_station_latitude),
    zip_start.zip_code_geom)
INNER JOIN `bigquery-public-data.geo_us_boundaries.zip_codes` zip_end
  ON ST_WITHIN(
    ST_GEOGPOINT(trip.end_station_longitude, trip.end_station_latitude),
    zip_end.zip_code_geom)
INNER JOIN `bigquery-public-data.noaa_gsod.gsod201*` w
  ON PARSE_DATE('%Y%m%d', CONCAT(w.year, w.mo, w.da)) = DATE(trip.starttime)
WHERE 
  -- Filter by weather station in New York Central Park
  w.wban IN (SELECT DISTINCT wban FROM `bigquery-public-data.noaa_gsod.stations` WHERE name = 'NEW YORK CENTRAL PARK') 
  -- Limit data to the year 2018
  AND EXTRACT(YEAR FROM DATE(trip.starttime)) = 2018
GROUP BY 
  trip.usertype
ORDER BY avg_temperature DESC
LIMIT 1;