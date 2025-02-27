SELECT 
  district
FROM (
  SELECT
    S.starting_district AS district,
    T.start_station_id,
    T.end_station_id
  FROM
    `bigquery-public-data.austin_bikeshare.bikeshare_trips` AS T
  INNER JOIN (
    SELECT
      station_id,
      council_district AS starting_district
    FROM
      `bigquery-public-data.austin_bikeshare.bikeshare_stations`
    WHERE
      status = "active"
  ) AS S ON T.start_station_id = S.station_id
  WHERE
    S.starting_district IN (
      SELECT council_district
      FROM `bigquery-public-data.austin_bikeshare.bikeshare_stations`
      WHERE
        status = "active" AND
        station_id = SAFE_CAST(T.end_station_id AS INT64)
    )
    AND T.start_station_id != SAFE_CAST(T.end_station_id AS INT64)
) 
GROUP BY district
ORDER BY COUNT(*) DESC
LIMIT 1;
