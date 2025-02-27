WITH stations AS (
  SELECT station_id
  FROM
    `bigquery-public-data.san_francisco_bikeshare.bikeshare_station_info` AS stainfo
  WHERE stainfo.region_id = (
    SELECT region.region_id
    FROM `bigquery-public-data.san_francisco_bikeshare.bikeshare_regions` AS region
    WHERE region.name = "Berkeley"
  )
),
meta_data AS (
    SELECT
        round(st_distance(start_station_geom, end_station_geom), 1) as distancia_metros,
        round(st_distance(start_station_geom, end_station_geom) / duration_sec, 1) as velocidade_media
    FROM
        `bigquery-public-data.san_francisco_bikeshare.bikeshare_trips` AS trips
    WHERE
        cast(trips.start_station_id as string) IN (SELECT station_id FROM stations)
        AND cast(trips.end_station_id as string) IN (SELECT station_id FROM stations)
        AND start_station_latitude IS NOT NULL
        AND start_station_longitude IS NOT NULL
        AND end_station_latitude IS NOT NULL
        AND end_station_longitude IS NOT NULL
        AND st_distance(start_station_geom, end_station_geom) > 1000
    ORDER BY
        velocidade_media DESC
    LIMIT 1
)

SELECT velocidade_media as max_velocity
FROM meta_data;