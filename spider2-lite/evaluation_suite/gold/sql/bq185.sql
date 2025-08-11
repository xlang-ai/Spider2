SELECT 
    AVG(TIMESTAMP_DIFF(dropoff_datetime, pickup_datetime, SECOND) / 60.0) AS average_trip_duration_in_minutes
FROM
(
    SELECT *
    FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2016` t
    WHERE 
        pickup_datetime BETWEEN '2016-02-01' AND '2016-02-07' AND 
        dropoff_datetime BETWEEN '2016-02-01' AND '2016-02-07' AND
        TIMESTAMP_DIFF(dropoff_datetime, pickup_datetime, SECOND) > 0 AND 
        passenger_count > 3 AND 
        trip_distance >= 10
) t
INNER JOIN `bigquery-public-data.new_york_taxi_trips.taxi_zone_geom` tz
ON t.pickup_location_id = tz.zone_id
INNER JOIN `bigquery-public-data.new_york_taxi_trips.taxi_zone_geom` tz1
ON t.dropoff_location_id = tz1.zone_id
WHERE 
    tz.borough = "Brooklyn" AND
    tz1.borough = "Brooklyn";
