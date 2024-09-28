WITH params AS (
  SELECT ST_GeogPoint(-74.0060, 40.7128) AS center,
         50 AS maxn_stations,
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
),
station_ids AS (
SELECT id, dist_meters from nearest_nstations
ORDER BY dist_meters ASC
LIMIT 1000
),
bicycle_rentals AS (
  SELECT
    COUNT(starttime) as num_trips,
    EXTRACT(DATE from starttime) as trip_date
  FROM `bigquery-public-data.new_york_citibike.citibike_trips`
  GROUP BY trip_date
),
closest AS (
  SELECT
    station_ids.id as id,
    ANY_VALUE(station_ids.dist_meters) as dist
  FROM
    `bigquery-public-data.ghcn_d.ghcnd_2016` AS wx
  JOIN station_ids
  on wx.id=station_ids.id
  GROUP BY station_ids.id
  ORDER BY dist ASC
  LIMIT 1
),
rainy_days AS
(
SELECT
  date,
  (COALESCE(MAX(prcp), 0) > 0) AS rainy
FROM (
  SELECT
    wx.date AS date,
    IF (wx.element = 'PRCP', wx.value/10, NULL) AS prcp
  FROM
    `bigquery-public-data.ghcn_d.ghcnd_2016` AS wx
  WHERE
    wx.id in (SELECT id FROM closest)
)
GROUP BY
 date
)

SELECT
  ROUND(AVG(bk.num_trips)) AS num_trips,
  wx.rainy
FROM bicycle_rentals AS bk
JOIN rainy_days AS wx
ON wx.date = bk.trip_date
GROUP BY wx.rainy


