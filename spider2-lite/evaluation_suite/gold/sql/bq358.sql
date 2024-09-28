SELECT
--  TRI.usertype,
--  TRI.start_station_longitude,
--  TRI.start_station_latitude,
--  TRI.end_station_longitude,
--  TRI.end_station_latitude,
 ZIPSTART.zip_code AS zip_code_start,
 ZIPEND.zip_code AS zip_code_end,
--  WEA.temp AS day_mean_temperature, -- Mean temp
--  WEA.wdsp AS day_mean_wind_speed, -- Mean wind speed
--  WEA.prcp day_total_precipitation, -- Total precipitation
--  TRI.bikeid
FROM  
 `bigquery-public-data.new_york_citibike.citibike_trips` AS TRI
INNER JOIN
`bigquery-public-data.geo_us_boundaries.zip_codes` ZIPSTART
ON ST_WITHIN(
ST_GEOGPOINT(TRI.start_station_longitude, TRI.start_station_latitude),
 ZIPSTART.zip_code_geom)
INNER JOIN
`bigquery-public-data.geo_us_boundaries.zip_codes` ZIPEND
ON ST_WITHIN(
 ST_GEOGPOINT(TRI.end_station_longitude, TRI.end_station_latitude),
ZIPEND.zip_code_geom)
INNER JOIN
 `bigquery-public-data.noaa_gsod.gsod2015` AS WEA
 ON PARSE_DATE("%Y%m%d", CONCAT(WEA.year, WEA.mo, WEA.da)) = DATE(TRI.starttime)
WHERE
-- Take the weather from one weather station
  WEA.wban = '94728' -- NEW YORK CENTRAL PARK
 -- Use data for three summer months
AND DATE(TRI.starttime) BETWEEN DATE('2015-07-01') AND DATE('2015-09-30')
ORDER BY WEA.temp DESC LIMIT 1