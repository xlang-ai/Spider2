WITH weather_check AS (
    SELECT "temp"
    FROM NEW_YORK_CITIBIKE_1.NOAA_GSOD.GSOD2015
    WHERE "wban" = '94728'
      AND "mo" = '07'
      AND "da" = '15'
),
nyc_zips AS (
    SELECT "zip_code", TO_GEOGRAPHY("zip_code_geom") AS geom
    FROM NEW_YORK_CITIBIKE_1.GEO_US_BOUNDARIES.ZIP_CODES
    WHERE "state_code" = 'NY' AND "city" ILIKE '%New York%'
),
jul15_trips AS (
    SELECT
        t."bikeid",
        ST_POINT(t."start_station_longitude", t."start_station_latitude") AS start_pt,
        ST_POINT(t."end_station_longitude", t."end_station_latitude") AS end_pt
    FROM NEW_YORK_CITIBIKE_1.NEW_YORK_CITIBIKE.CITIBIKE_TRIPS t
    CROSS JOIN weather_check w
    WHERE TO_TIMESTAMP(t."starttime" / 1000000)::DATE = '2015-07-15'
)
SELECT
    sz."zip_code" AS start_zip,
    ez."zip_code" AS end_zip
FROM jul15_trips jt
JOIN nyc_zips sz ON ST_CONTAINS(sz.geom, jt.start_pt)
JOIN nyc_zips ez ON ST_CONTAINS(ez.geom, jt.end_pt)
ORDER BY start_zip ASC, end_zip DESC
LIMIT 1;