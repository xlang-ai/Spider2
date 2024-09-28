SELECT
  bike_number, 
  AVG(dist_in_m) AS avg_dist_m, 
  SUM(dist_in_m) AS total_dist_m
FROM (
  SELECT
    ST_DISTANCE(
      ST_GEOGPOINT(start_lon, start_lat),
      ST_GEOGPOINT(end_lon, end_lat)
    ) AS dist_in_m,
    starts.bike_number
  FROM (
    SELECT 
      latitude AS start_lat,
      longitude AS start_lon,
      bike_number,
      trip_id
    FROM `bigquery-public-data.san_francisco.bikeshare_trips` trips
    LEFT JOIN `bigquery-public-data.san_francisco.bikeshare_stations` stations
      ON trips.start_station_id = stations.station_id
  ) starts
  LEFT JOIN (
    SELECT 
      latitude AS end_lat,
      longitude AS end_lon,
      bike_number,
      trip_id
    FROM `bigquery-public-data.san_francisco.bikeshare_trips` trips
    LEFT JOIN `bigquery-public-data.san_francisco.bikeshare_stations` stations
      ON trips.end_station_id = stations.station_id
  ) ends ON ends.trip_id = starts.trip_id
)
GROUP BY bike_number
ORDER BY total_dist_m DESC