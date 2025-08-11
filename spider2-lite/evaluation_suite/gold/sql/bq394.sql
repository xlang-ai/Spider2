WITH DailyAverages AS (
    SELECT 
        year, month, day,
        air_temperature,
        wetbulb_temperature,
        dewpoint_temperature,
        sea_surface_temp
    FROM 
        `bigquery-public-data.noaa_icoads.icoads_core_*`
    WHERE
        _TABLE_SUFFIX BETWEEN '2010' AND '2014'
),

MonthlyAverages AS (
    SELECT 
        year,
        month,
        AVG(air_temperature) AS avg_air_temperature,
        AVG(wetbulb_temperature) AS avg_wetbulb_temperature,
        AVG(dewpoint_temperature) AS avg_dewpoint_temperature,
        AVG(sea_surface_temp) AS avg_sea_surface_temp
    FROM 
        DailyAverages
    WHERE
        air_temperature IS NOT NULL
        AND wetbulb_temperature IS NOT NULL
        AND dewpoint_temperature IS NOT NULL
        AND sea_surface_temp IS NOT NULL
    GROUP BY 
        year, month
),

DifferenceSums AS (
    SELECT
        year,
        month,
        (ABS(avg_air_temperature - avg_wetbulb_temperature) +
        ABS(avg_air_temperature - avg_dewpoint_temperature) +
        ABS(avg_air_temperature - avg_sea_surface_temp) +
        ABS(avg_wetbulb_temperature - avg_dewpoint_temperature) +
        ABS(avg_wetbulb_temperature - avg_sea_surface_temp) +
        ABS(avg_dewpoint_temperature - avg_sea_surface_temp)) AS sum_of_differences
    FROM 
        MonthlyAverages
)

SELECT
    year,
    month,
    sum_of_differences
FROM
    DifferenceSums
ORDER BY
    sum_of_differences ASC
LIMIT 3;