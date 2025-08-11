WITH daily_forecasts AS (
    SELECT
        "TRI"."creation_time",

        CAST(DATEADD(hour, 1, TO_TIMESTAMP_NTZ(TO_NUMBER("forecast".value:"time") / 1000000)) AS DATE) AS "local_forecast_date",
        MAX(
            CASE 
                WHEN "forecast".value:"temperature_2m_above_ground" IS NOT NULL 
                THEN "forecast".value:"temperature_2m_above_ground" 
                ELSE NULL 
            END
        ) AS "max_temp",
        MIN(
            CASE 
                WHEN "forecast".value:"temperature_2m_above_ground" IS NOT NULL 
                THEN "forecast".value:"temperature_2m_above_ground" 
                ELSE NULL 
            END
        ) AS "min_temp",
        AVG(
            CASE 
                WHEN "forecast".value:"temperature_2m_above_ground" IS NOT NULL 
                THEN "forecast".value:"temperature_2m_above_ground" 
                ELSE NULL 
            END
        ) AS "avg_temp",
        SUM(
            CASE 
                WHEN "forecast".value:"total_precipitation_surface" IS NOT NULL 
                THEN "forecast".value:"total_precipitation_surface" 
                ELSE 0 
            END
        ) AS "total_precipitation",
        AVG(
            CASE 
                WHEN CAST(DATEADD(hour, 1, TO_TIMESTAMP_NTZ(TO_NUMBER("forecast".value:"time") / 1000000)    ) AS TIME) BETWEEN '10:00:00' AND '17:00:00'
                     AND "forecast".value:"total_cloud_cover_entire_atmosphere" IS NOT NULL 
                THEN "forecast".value:"total_cloud_cover_entire_atmosphere" 
                ELSE NULL 
            END
        ) AS "avg_cloud_cover",
        CASE
            WHEN AVG("forecast".value:"temperature_2m_above_ground") < 32 THEN 
                SUM(
                    CASE 
                        WHEN "forecast".value:"total_precipitation_surface" IS NOT NULL 
                        THEN "forecast".value:"total_precipitation_surface" 
                        ELSE 0 
                    END
                )
            ELSE 0
        END AS "total_snow",
        CASE
            WHEN AVG("forecast".value:"temperature_2m_above_ground") >= 32 THEN 
                SUM(
                    CASE 
                        WHEN "forecast".value:"total_precipitation_surface" IS NOT NULL 
                        THEN "forecast".value:"total_precipitation_surface" 
                        ELSE 0 
                    END
                )
            ELSE 0
        END AS "total_rain"
    FROM
        "NOAA_GLOBAL_FORECAST_SYSTEM"."NOAA_GLOBAL_FORECAST_SYSTEM"."NOAA_GFS0P25" AS "TRI"
    CROSS JOIN LATERAL FLATTEN(input => "TRI"."forecast") AS "forecast"
    WHERE
        TO_TIMESTAMP_NTZ(TO_NUMBER("TRI"."creation_time") / 1000000) BETWEEN '2019-07-01' AND '2021-07-31'  
        AND ST_DWITHIN(
            ST_GEOGFROMWKB("TRI"."geography"),
            ST_POINT(26.75, 51.5),
            5000
        )
        AND CAST(TO_TIMESTAMP_NTZ(TO_NUMBER("forecast".value:"time") / 1000000) AS DATE) = DATEADD(day, 1, CAST( TO_TIMESTAMP_NTZ(TO_NUMBER("TRI"."creation_time") / 1000000) AS DATE))
    GROUP BY
        "TRI"."creation_time",
        "local_forecast_date"
)

SELECT
    TO_TIMESTAMP_NTZ(TO_NUMBER("creation_time") / 1000000),
    "local_forecast_date" AS "forecast_date",
    "max_temp",
    "min_temp",
    "avg_temp",
    "total_precipitation",
    "avg_cloud_cover",
    "total_snow",
    "total_rain"
FROM
    daily_forecasts
ORDER BY
    "creation_time",
    "forecast_date";
