SELECT
    t.year,
    CASE 
        WHEN t.year = 2013 THEN (
                                  SELECT 
                                    COUNT(DISTINCT station_id)
                                  FROM 
                                    `bigquery-public-data.austin_bikeshare.bikeshare_trips` t
                                  INNER JOIN 
                                    `bigquery-public-data.austin_bikeshare.bikeshare_stations` s
                                  ON 
                                    t.start_station_id = s.station_id
                                  WHERE 
                                    s.status = 'active' AND EXTRACT(YEAR FROM start_time) = 2013
                                 ) 
        WHEN t.year = 2014 THEN (
                                  SELECT 
                                    COUNT(DISTINCT station_id)
                                  FROM 
                                    `bigquery-public-data.austin_bikeshare.bikeshare_trips` t
                                  INNER JOIN 
                                    `bigquery-public-data.austin_bikeshare.bikeshare_stations` s
                                  ON 
                                    t.start_station_id = s.station_id
                                  WHERE 
                                    s.status = 'active' AND EXTRACT(YEAR FROM start_time) = 2014
                                 )
    END
    AS number_status_active,
    CASE 
        WHEN t.year = 2013 THEN (
                                  SELECT 
                                   COUNT(DISTINCT station_id)
                                  FROM 
                                  `bigquery-public-data.austin_bikeshare.bikeshare_trips` t
                                  INNER JOIN 
                                  `bigquery-public-data.austin_bikeshare.bikeshare_stations` s
                                  ON 
                                   t.start_station_id = s.station_id
                                  WHERE 
                                   s.status = 'closed' AND EXTRACT(YEAR FROM start_time) = 2013
                                 ) 
        WHEN t.year = 2014 THEN (
                                  SELECT 
                                  COUNT(DISTINCT station_id)
                                  FROM 
                                    `bigquery-public-data.austin_bikeshare.bikeshare_trips` t
                                  INNER JOIN 
                                    `bigquery-public-data.austin_bikeshare.bikeshare_stations` s
                                  ON 
                                    t.start_station_id = s.station_id
                                  WHERE 
                                    s.status = 'closed' AND EXTRACT(YEAR FROM start_time) = 2014
                                 )
    END
    AS number_status_closed
FROM
    (
      SELECT 
         EXTRACT(YEAR FROM start_time) AS year,
         start_station_id
      FROM
         `bigquery-public-data.austin_bikeshare.bikeshare_trips`
    ) 
    AS t
INNER JOIN
    `bigquery-public-data.austin_bikeshare.bikeshare_stations` s
ON
    t.start_station_id = s.station_id
WHERE
    t.year BETWEEN 2013 AND 2014
GROUP BY
    t.year
ORDER BY
    t.year