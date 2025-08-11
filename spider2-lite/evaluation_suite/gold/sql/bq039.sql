SELECT 
    tz.zone_name AS pickup_zone,
    tz1.zone_name AS dropoff_zone, 
    time_duration_in_secs,
    driving_speed_miles_per_hour,
    tip_rate
FROM
(
SELECT *,
    TIMESTAMP_DIFF(dropoff_datetime,pickup_datetime,SECOND) as time_duration_in_secs,
    ROUND(trip_distance / (TIMESTAMP_DIFF(dropoff_datetime, pickup_datetime, SECOND) / 3600), 2) AS driving_speed_miles_per_hour,
    (CASE WHEN total_amount=0 THEN 0
          ELSE (tip_amount*100/total_amount) END) as tip_rate
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2016`
) t
INNER JOIN `bigquery-public-data.new_york_taxi_trips.taxi_zone_geom` tz
ON t.pickup_location_id = tz.zone_id
INNER JOIN `bigquery-public-data.new_york_taxi_trips.taxi_zone_geom` tz1
ON t.dropoff_location_id = tz1.zone_id
WHERE 
    pickup_datetime BETWEEN '2016-07-01' AND '2016-07-07' 
    AND dropoff_datetime BETWEEN '2016-07-01' AND '2016-07-07'
    AND TIMESTAMP_DIFF(dropoff_datetime,pickup_datetime,SECOND) > 0
    AND passenger_count > 5
    AND trip_distance >= 10
    AND tip_amount >= 0 
    AND tolls_amount >= 0 
    AND mta_tax >= 0 
    AND fare_amount >= 0
    AND total_amount >= 0
ORDER BY total_amount DESC
LIMIT 10;
