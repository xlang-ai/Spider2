WITH threshold AS (
    SELECT DATEADD(year, -10, CURRENT_DATE()) AS min_event_date
),
hail_events AS (
    SELECT TO_TIMESTAMP_NTZ("event_begin_time" / 1000000) AS event_ts,
           "event_latitude" AS event_lat,
           "event_longitude" AS event_lon
    FROM "NOAA_DATA_PLUS"."NOAA_HISTORIC_SEVERE_STORMS"."STORMS_2014"
    WHERE UPPER("event_type") = 'HAIL' AND "event_latitude" IS NOT NULL AND "event_longitude" IS NOT NULL
    UNION ALL
    SELECT TO_TIMESTAMP_NTZ("event_begin_time" / 1000000), "event_latitude", "event_longitude"
    FROM "NOAA_DATA_PLUS"."NOAA_HISTORIC_SEVERE_STORMS"."STORMS_2015"
    WHERE UPPER("event_type") = 'HAIL' AND "event_latitude" IS NOT NULL AND "event_longitude" IS NOT NULL
    UNION ALL
    SELECT TO_TIMESTAMP_NTZ("event_begin_time" / 1000000), "event_latitude", "event_longitude"
    FROM "NOAA_DATA_PLUS"."NOAA_HISTORIC_SEVERE_STORMS"."STORMS_2016"
    WHERE UPPER("event_type") = 'HAIL' AND "event_latitude" IS NOT NULL AND "event_longitude" IS NOT NULL
    UNION ALL
    SELECT TO_TIMESTAMP_NTZ("event_begin_time" / 1000000), "event_latitude", "event_longitude"
    FROM "NOAA_DATA_PLUS"."NOAA_HISTORIC_SEVERE_STORMS"."STORMS_2017"
    WHERE UPPER("event_type") = 'HAIL' AND "event_latitude" IS NOT NULL AND "event_longitude" IS NOT NULL
    UNION ALL
    SELECT TO_TIMESTAMP_NTZ("event_begin_time" / 1000000), "event_latitude", "event_longitude"
    FROM "NOAA_DATA_PLUS"."NOAA_HISTORIC_SEVERE_STORMS"."STORMS_2018"
    WHERE UPPER("event_type") = 'HAIL' AND "event_latitude" IS NOT NULL AND "event_longitude" IS NOT NULL
    UNION ALL
    SELECT TO_TIMESTAMP_NTZ("event_begin_time" / 1000000), "event_latitude", "event_longitude"
    FROM "NOAA_DATA_PLUS"."NOAA_HISTORIC_SEVERE_STORMS"."STORMS_2019"
    WHERE UPPER("event_type") = 'HAIL' AND "event_latitude" IS NOT NULL AND "event_longitude" IS NOT NULL
    UNION ALL
    SELECT TO_TIMESTAMP_NTZ("event_begin_time" / 1000000), "event_latitude", "event_longitude"
    FROM "NOAA_DATA_PLUS"."NOAA_HISTORIC_SEVERE_STORMS"."STORMS_2020"
    WHERE UPPER("event_type") = 'HAIL' AND "event_latitude" IS NOT NULL AND "event_longitude" IS NOT NULL
    UNION ALL
    SELECT TO_TIMESTAMP_NTZ("event_begin_time" / 1000000), "event_latitude", "event_longitude"
    FROM "NOAA_DATA_PLUS"."NOAA_HISTORIC_SEVERE_STORMS"."STORMS_2021"
    WHERE UPPER("event_type") = 'HAIL' AND "event_latitude" IS NOT NULL AND "event_longitude" IS NOT NULL
    UNION ALL
    SELECT TO_TIMESTAMP_NTZ("event_begin_time" / 1000000), "event_latitude", "event_longitude"
    FROM "NOAA_DATA_PLUS"."NOAA_HISTORIC_SEVERE_STORMS"."STORMS_2022"
    WHERE UPPER("event_type") = 'HAIL' AND "event_latitude" IS NOT NULL AND "event_longitude" IS NOT NULL
    UNION ALL
    SELECT TO_TIMESTAMP_NTZ("event_begin_time" / 1000000), "event_latitude", "event_longitude"
    FROM "NOAA_DATA_PLUS"."NOAA_HISTORIC_SEVERE_STORMS"."STORMS_2023"
    WHERE UPPER("event_type") = 'HAIL' AND "event_latitude" IS NOT NULL AND "event_longitude" IS NOT NULL
    UNION ALL
    SELECT TO_TIMESTAMP_NTZ("event_begin_time" / 1000000), "event_latitude", "event_longitude"
    FROM "NOAA_DATA_PLUS"."NOAA_HISTORIC_SEVERE_STORMS"."STORMS_2024"
    WHERE UPPER("event_type") = 'HAIL' AND "event_latitude" IS NOT NULL AND "event_longitude" IS NOT NULL
),
recent_hail AS (
    SELECT e.event_ts, e.event_lat, e.event_lon
    FROM hail_events e
    JOIN threshold t ON e.event_ts >= t.min_event_date
),
hail_with_zip AS (
    SELECT z."zip_code",
           COUNT(*) AS hail_event_count
    FROM recent_hail r
    JOIN "NOAA_DATA_PLUS"."GEO_US_BOUNDARIES"."ZIP_CODES" z
      ON ST_WITHIN(ST_POINT(r.event_lon, r.event_lat), TO_GEOGRAPHY(z."zip_code_geom"))
    GROUP BY z."zip_code"
)
SELECT "zip_code", hail_event_count
FROM hail_with_zip
ORDER BY hail_event_count DESC, "zip_code"
FETCH FIRST 5 ROWS ONLY;