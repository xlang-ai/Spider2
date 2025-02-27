WITH DailyAverages AS (
    SELECT 
        year, month, day, latitude, longitude,
        AVG(wind_speed) AS avg_wind_speed,
    FROM 
        `bigquery-public-data.noaa_icoads.icoads_core_*`
    WHERE
        _TABLE_SUFFIX BETWEEN '2005' AND '2015'
    GROUP BY 
        year, month, day, latitude, longitude
)
SELECT 
    year, month, day, latitude, longitude,
    avg_wind_speed,

FROM 
    DailyAverages
WHERE
    avg_wind_speed IS NOT NULL

ORDER BY avg_wind_speed DESC LIMIT 5