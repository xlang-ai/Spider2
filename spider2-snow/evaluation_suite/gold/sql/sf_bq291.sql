WITH "pts" AS (
  SELECT
    "creation_time",
    TO_DATE(TO_TIMESTAMP_NTZ("creation_time" / 1000000)) AS "creation_date",
    "forecast",
    "geography",
    "geography_polygon"
  FROM "NOAA_GLOBAL_FORECAST_SYSTEM"."NOAA_GLOBAL_FORECAST_SYSTEM"."NOAA_GFS0P25"
  WHERE TO_DATE(TO_TIMESTAMP_NTZ("creation_time" / 1000000)) BETWEEN '2019-07-01' AND '2019-07-31'
    AND (
      (TO_GEOGRAPHY("geography") IS NOT NULL AND (
         ST_DISTANCE(TO_GEOGRAPHY("geography"), TO_GEOGRAPHY('POINT(51.5 26.75)')) <= 5000
         OR ST_DISTANCE(TO_GEOGRAPHY("geography"), TO_GEOGRAPHY('POINT(26.75 51.5)')) <= 5000
       ))
      OR (TO_GEOGRAPHY("geography_polygon") IS NOT NULL AND (
         ST_CONTAINS(TO_GEOGRAPHY("geography_polygon"), TO_GEOGRAPHY('POINT(51.5 26.75)'))
         OR ST_CONTAINS(TO_GEOGRAPHY("geography_polygon"), TO_GEOGRAPHY('POINT(26.75 51.5)'))
       ))
    )
),
"flat" AS (
  SELECT
    p."creation_date" AS "creation_date",
    TO_DATE(TO_TIMESTAMP_NTZ(("f"."VALUE":"time")::NUMBER / 1000000)) AS "forecast_date",
    EXTRACT(HOUR FROM TO_TIMESTAMP_NTZ(("f"."VALUE":"time")::NUMBER / 1000000)) AS "forecast_hour",
    ((("f"."VALUE":"temperature_2m_above_ground")::FLOAT) * 9.0/5.0) + 32 AS "temp_f",
    COALESCE(("f"."VALUE":"total_precipitation_surface")::FLOAT, 0) AS "precip",
    ("f"."VALUE":"total_cloud_cover_entire_atmosphere")::FLOAT AS "cloud_cover"
  FROM "pts" p,
       LATERAL FLATTEN(input => p."forecast") AS "f"
),
"daily" AS (
  SELECT
    "forecast_date",
    MAX("temp_f") AS "max_temp_f",
    MIN("temp_f") AS "min_temp_f",
    AVG("temp_f") AS "avg_temp_f",
    SUM("precip") AS "total_precipitation",
    AVG(CASE WHEN "forecast_hour" BETWEEN 10 AND 17 THEN "cloud_cover" END) AS "avg_cloud_cover_10am_5pm"
  FROM "flat"
  WHERE "forecast_date" = DATEADD('day', 1, "creation_date")
    AND "forecast_date" BETWEEN '2019-07-01' AND '2019-07-31'
  GROUP BY "forecast_date"
)
SELECT
  "forecast_date",
  "max_temp_f" AS "max_temperature_f",
  "min_temp_f" AS "min_temperature_f",
  "avg_temp_f" AS "avg_temperature_f",
  "total_precipitation",
  "avg_cloud_cover_10am_5pm",
  CASE WHEN "avg_temp_f" < 32 THEN "total_precipitation" ELSE 0 END AS "total_snowfall",
  CASE WHEN "avg_temp_f" >= 32 THEN "total_precipitation" ELSE 0 END AS "total_rainfall"
FROM "daily"
ORDER BY "forecast_date" ASC;