WITH popular_station AS (
  SELECT
    start_station_name,
    start_station_id,
    COUNT(*) AS number_trips
  FROM
    `bigquery-public-data.new_york_citibike.citibike_trips`
  WHERE 
    starttime >= '2018-01-01T00:00:00'
  GROUP BY
    start_station_name, start_station_id
  ORDER BY number_trips DESC
  LIMIT 1
),

daily_data AS (
  SELECT
    extract(DAYOFWEEK FROM starttime) AS day_of_week,
    COUNT(*) AS trips_count
  FROM
    `bigquery-public-data.new_york_citibike.citibike_trips`
  WHERE 
    start_station_id = (SELECT start_station_id FROM popular_station)
    AND starttime >= '2018-01-01'
  GROUP BY
    day_of_week
  ORDER BY trips_count DESC
  LIMIT 1
),

hourly_data AS (
  SELECT
    extract(HOUR FROM starttime) AS hour,
    COUNT(*) AS trips_count
  FROM
    `bigquery-public-data.new_york_citibike.citibike_trips`
  WHERE 
    start_station_id = (SELECT start_station_id FROM popular_station)
    AND starttime >= '2018-01-01'
  GROUP BY
    hour
  ORDER BY trips_count DESC
  LIMIT 1
)

SELECT
  (SELECT start_station_name FROM popular_station) AS station_name,
  (SELECT day_of_week FROM daily_data) AS peak_day_of_week,
  (SELECT hour FROM hourly_data) AS peak_hour
