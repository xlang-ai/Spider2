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
      AND name != "NOT_NAMED"),

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
  port_name
FROM
  ts_wind_polygon t,
  `bigquery-public-data.geo_international_ports.world_port_index` p,
  `bigquery-public-data.geo_us_boundaries.states` s
JOIN
  `bigquery-public-data.noaa_hurricanes.hurricanes` h ON h.sid = t.storm_id
WHERE
  port_name IS NOT NULL
  AND region_number = '6585'
  AND ST_WITHIN(port_geom, state_geom)
  AND ST_WITHIN(port_geom, tropical_storm_geom)
GROUP BY
  port_name,
  s.state_name
ORDER BY
  COUNT(DISTINCT(storm_id)) DESC
LIMIT 1;