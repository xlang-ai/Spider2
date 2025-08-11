WITH top20route AS (
SELECT
  start_station_name, end_station_name, avg_bike_duration, avg_taxi_duration
FROM (
  SELECT
    start_station_name,
    end_station_name,
    ROUND(start_station_latitude, 3) AS ss_lat,
    ROUND(start_station_longitude, 3) AS ss_long,
    ROUND(end_station_latitude, 3) AS es_lat,
    ROUND(end_station_longitude, 3) AS es_long,
    AVG(tripduration) AS avg_bike_duration,
    COUNT(*) AS bike_trips
  FROM
    `bigquery-public-data.new_york.citibike_trips`
  WHERE 
  EXTRACT(YEAR from starttime) = 2016 AND
    start_station_name != end_station_name
  GROUP BY
    start_station_name, end_station_name, ss_lat, ss_long, es_lat, es_long
  ORDER BY
    bike_trips DESC
  LIMIT
    20
) a
JOIN (
  SELECT
    ROUND(pickup_latitude, 3) AS pu_lat,
    ROUND(pickup_longitude, 3) AS pu_long,
    ROUND(dropoff_latitude, 3) AS do_lat,
    ROUND(dropoff_longitude, 3) AS do_long,
    AVG(UNIX_SECONDS(dropoff_datetime)-UNIX_SECONDS(pickup_datetime)) AS avg_taxi_duration,
    COUNT(*) AS taxi_trips
  FROM
    `bigquery-public-data.new_york.tlc_yellow_trips_2016`
  GROUP BY
    pu_lat, pu_long, do_lat, do_long
) b
ON
  a.ss_lat = b.pu_lat AND
  a.es_lat = b.do_lat AND
  a.ss_long = b.pu_long AND
  a.es_long = b.do_long
)

SELECT start_station_name
FROM top20route
WHERE avg_bike_duration < avg_taxi_duration
ORDER BY
avg_bike_duration
DESC
LIMIT 1
