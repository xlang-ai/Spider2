SELECT
  COUNT(1) AS num_rides
FROM
  `bigquery-public-data.austin_bikeshare.bikeshare_trips` 
WHERE 
start_station_name 
    NOT IN ('Mobile Station', 'Repair Shop')
AND
end_station_name 
    NOT IN ('Mobile Station', 'Repair Shop')
AND 
subscriber_type = 'Student Membership'
AND
bike_type = 'electric'
AND
duration_minutes > 10
GROUP BY 
    EXTRACT(YEAR from start_time), 
    EXTRACT(MONTH from start_time), 
    EXTRACT(DAY from start_time)
ORDER BY num_rides DESC
LIMIT 1