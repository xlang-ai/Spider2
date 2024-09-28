DECLARE ne INT64 DEFAULT 45;
DECLARE se INT64 DEFAULT 135;
DECLARE sw INT64 DEFAULT 225;
DECLARE nw INT64 DEFAULT 315;

WITH convert_miles AS (
    SELECT
      sid AS storm_id,
      season,
      latitude,
      longitude,
      `bigquery-public-data.persistent_udfs.nautical_miles_conversion`(usa_r34_ne) AS usa_r34_ne,
      `bigquery-public-data.persistent_udfs.nautical_miles_conversion`(usa_r34_se) AS usa_r34_se,
      `bigquery-public-data.persistent_udfs.nautical_miles_conversion`(usa_r34_sw) AS usa_r34_sw,
      `bigquery-public-data.persistent_udfs.nautical_miles_conversion`(usa_r34_nw) AS usa_r34_nw
    FROM
      `bigquery-public-data.noaa_hurricanes.hurricanes`
    WHERE
      basin = "NA"
      AND usa_wind >= 35
      AND name != "NOT_NAMED"
      AND usa_sshs >= -1),

ts_wind_polygon AS (
    SELECT
      storm_id,
      season,
      ST_MakePolygon(
        ST_MakeLine([
          `bigquery-public-data.persistent_udfs.azimuth_to_geog_point`(latitude, longitude, ne, usa_r34_ne),
          `bigquery-public-data.persistent_udfs.azimuth_to_geog_point`(latitude, longitude, se, usa_r34_se),
          `bigquery-public-data.persistent_udfs.azimuth_to_geog_point`(latitude, longitude, sw, usa_r34_sw),
          `bigquery-public-data.persistent_udfs.azimuth_to_geog_point`(latitude, longitude, nw, usa_r34_nw)]
        )
      ) AS tropical_storm_geom
  FROM
      convert_miles)

SELECT
  index_number,
  port_name,
  state_name,
  STRING_AGG(DISTINCT(h.season)) AS storm_years,
  COUNT(DISTINCT(storm_id)) AS count_storms,
  STRING_AGG(DISTINCT(name)) AS storm_name,
  AVG(usa_sshs) AS avg_storm_cat,
  AVG(usa_wind) AS avg_wind_speed,
  ST_AsText(port_geom) AS port_geom,
  ST_AsText(tropical_storm_geom) AS tropical_storm_geom
FROM
  ts_wind_polygon t,
  `bigquery-public-data.geo_international_ports.world_port_index` ,
  `bigquery-public-data.geo_us_boundaries.states` 
JOIN
  `bigquery-public-data.noaa_hurricanes.hurricanes` h ON h.sid = t.storm_id
WHERE
  port_name IS NOT NULL
  AND region_number = '6585'
  AND ST_WITHIN(port_geom, state_geom)
  AND ST_WITHIN(port_geom, tropical_storm_geom)
GROUP BY
  index_number,
  port_geom,
  port_name,
  state_name,
  tropical_storm_geom
ORDER BY
  avg_wind_speed DESC
LIMIT 1;