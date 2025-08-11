SELECT
  ROUND(MIN(trip_seconds) / 60, 0) AS min_minutes,
  ROUND(MAX(trip_seconds) / 60, 0) AS max_minutes,
  COUNT(*) AS total_trips,
  AVG(fare) AS average_fare
FROM (
  SELECT
    trip_seconds,
    NTILE(6) OVER (ORDER BY trip_seconds) AS quantile,
    fare
  FROM
    `bigquery-public-data.chicago_taxi_trips.taxi_trips`
  WHERE
    trip_seconds BETWEEN 0 AND 3600
)
GROUP BY
  quantile
ORDER BY
  min_minutes, max_minutes;