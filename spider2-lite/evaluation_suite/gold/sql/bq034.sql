WITH params AS (
  SELECT ST_GeogPoint(-87.63, 41.88) AS center,
         5 AS maxn_stations,
         50 AS maxdist_km
),
distance_from_center AS (
  SELECT
    id,
    name,
    state,
    ST_GeogPoint(longitude, latitude) AS loc,
    ST_Distance(ST_GeogPoint(longitude, latitude), params.center) AS dist_meters
  FROM
    `bigquery-public-data.ghcn_d.ghcnd_stations`,
    params
  WHERE ST_DWithin(ST_GeogPoint(longitude, latitude), params.center, params.maxdist_km*1000)
),
nearest_stations AS (
  SELECT 
    *, 
    RANK() OVER (ORDER BY dist_meters ASC) AS rank
  FROM 
    distance_from_center
),
nearest_nstations AS (
  SELECT 
    station.* 
  FROM 
    nearest_stations AS station, params
  WHERE 
    rank <= params.maxn_stations
)
SELECT * from nearest_nstations