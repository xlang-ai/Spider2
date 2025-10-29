WITH "trips_2014" AS (
  SELECT
    t.*,
    TO_TIMESTAMP_NTZ("starttime", 6) AS "start_ts"
  FROM "NEW_YORK_CITIBIKE_1"."NEW_YORK_CITIBIKE"."CITIBIKE_TRIPS" t
  WHERE YEAR(TO_TIMESTAMP_NTZ("starttime", 6)) = 2014
),
"trip_with_zips" AS (
  SELECT
    t.*,
    CAST(szs."zip_code" AS NUMBER) AS "start_zip",
    CAST(sze."zip_code" AS NUMBER) AS "end_zip"
  FROM "trips_2014" t
  JOIN "NEW_YORK_CITIBIKE_1"."GEO_US_BOUNDARIES"."ZIP_CODES" szs
    ON szs."state_code" = 'NY'
   AND ST_WITHIN(ST_POINT(t."start_station_longitude", t."start_station_latitude"), TO_GEOGRAPHY(szs."zip_code_geom"))
  JOIN "NEW_YORK_CITIBIKE_1"."GEO_US_BOUNDARIES"."ZIP_CODES" sze
    ON sze."state_code" = 'NY'
   AND ST_WITHIN(ST_POINT(t."end_station_longitude", t."end_station_latitude"), TO_GEOGRAPHY(sze."zip_code_geom"))
),
"trip_neighborhoods" AS (
  SELECT
    twz.*,
    czs."borough" AS "start_borough",
    czs."neighborhood" AS "start_neighborhood",
    cze."borough" AS "end_borough",
    cze."neighborhood" AS "end_neighborhood"
  FROM "trip_with_zips" twz
  JOIN "NEW_YORK_CITIBIKE_1"."CYCLISTIC"."ZIP_CODES" czs
    ON czs."zip" = twz."start_zip"
  JOIN "NEW_YORK_CITIBIKE_1"."CYCLISTIC"."ZIP_CODES" cze
    ON cze."zip" = twz."end_zip"
),
"weather_central_park" AS (
  SELECT
    w."year",
    w."mo",
    w."da",
    w."wban",
    NULLIF(w."temp", 9999.9) AS "temp_f",
    CAST(NULLIF(w."wdsp", '999.9') AS FLOAT) AS "wdsp_knots",
    NULLIF(w."prcp", 99.99) AS "prcp_inches"
  FROM "NEW_YORK_CITIBIKE_1"."NOAA_GSOD"."GSOD2014" w
  WHERE w."wban" = '94728' AND w."year" = '2014'
),
"trip_with_weather" AS (
  SELECT
    tn.*,
    wc."temp_f",
    wc."wdsp_knots",
    wc."prcp_inches"
  FROM "trip_neighborhoods" tn
  LEFT JOIN "weather_central_park" wc
    ON wc."mo" = LPAD(CAST(EXTRACT(MONTH FROM tn."start_ts") AS VARCHAR), 2, '0')
   AND wc."da" = LPAD(CAST(EXTRACT(DAY FROM tn."start_ts") AS VARCHAR), 2, '0')
   AND wc."year" = '2014'
),
"aggregated" AS (
  SELECT
    "start_borough",
    "start_neighborhood",
    "end_borough",
    "end_neighborhood",
    COUNT(*) AS "total_trips",
    ROUND(AVG("tripduration")/60, 1) AS "avg_trip_duration_min",
    ROUND(AVG("temp_f"), 1) AS "avg_temp",
    ROUND(AVG("wdsp_knots" * 0.514444), 1) AS "avg_wind_speed_ms",
    ROUND(AVG("prcp_inches" * 2.54), 1) AS "avg_precip_cm"
  FROM "trip_with_weather"
  GROUP BY "start_borough","start_neighborhood","end_borough","end_neighborhood"
),
"monthly_counts" AS (
  SELECT
    "start_neighborhood",
    "end_neighborhood",
    EXTRACT(MONTH FROM "start_ts") AS "month_num",
    COUNT(*) AS "trips_in_month"
  FROM "trip_with_weather"
  GROUP BY "start_neighborhood","end_neighborhood",EXTRACT(MONTH FROM "start_ts")
),
"top_month" AS (
  SELECT
    "start_neighborhood",
    "end_neighborhood",
    "month_num"
  FROM (
    SELECT
      "start_neighborhood",
      "end_neighborhood",
      "month_num",
      "trips_in_month",
      ROW_NUMBER() OVER (
        PARTITION BY "start_neighborhood","end_neighborhood"
        ORDER BY "trips_in_month" DESC, "month_num"
      ) AS "rn"
    FROM "monthly_counts"
  )
  WHERE "rn" = 1
)
SELECT
  a."start_borough",
  a."start_neighborhood",
  a."end_borough",
  a."end_neighborhood",
  a."total_trips",
  a."avg_trip_duration_min",
  a."avg_temp",
  a."avg_wind_speed_ms",
  a."avg_precip_cm",
  tm."month_num" AS "month_with_most_trips"
FROM "aggregated" a
JOIN "top_month" tm
  ON a."start_neighborhood" = tm."start_neighborhood" AND a."end_neighborhood" = tm."end_neighborhood"
ORDER BY a."start_borough", a."start_neighborhood", a."end_borough", a."end_neighborhood";