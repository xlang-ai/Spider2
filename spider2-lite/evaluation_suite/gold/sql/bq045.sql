WITH WashingtonStations2023 AS 
    (
        SELECT 
            weather.stn AS station_id,
            ANY_VALUE(station.name) AS name
        FROM
            `bigquery-public-data.noaa_gsod.stations` AS station
        INNER JOIN
            `bigquery-public-data.noaa_gsod.gsod2023` AS weather
        ON
            station.usaf = weather.stn
        WHERE
            station.state = 'WA' 
            AND 
            station.usaf != '999999'
        GROUP BY
            station_id
    ),
prcp2023 AS (
SELECT
    washington_stations.name,
    (
        SELECT 
            COUNT(*)
        FROM
            `bigquery-public-data.noaa_gsod.gsod2023` AS weather
        WHERE
            washington_stations.station_id = weather.stn
            AND
            prcp > 0
            AND
            prcp !=99.99
    )
    AS rainy_days
FROM 
    WashingtonStations2023 AS washington_stations
ORDER BY
    rainy_days DESC
),
WashingtonStations2022 AS 
    (
        SELECT 
            weather.stn AS station_id,
            ANY_VALUE(station.name) AS name
        FROM
            `bigquery-public-data.noaa_gsod.stations` AS station
        INNER JOIN
            `bigquery-public-data.noaa_gsod.gsod2022` AS weather
        ON
            station.usaf = weather.stn
        WHERE
            station.state = 'WA' 
            AND 
            station.usaf != '999999'
        GROUP BY
            station_id
    ),
prcp2022 AS (
SELECT
    washington_stations.name,
    (
        SELECT 
            COUNT(*)
        FROM
            `bigquery-public-data.noaa_gsod.gsod2022` AS weather
        WHERE
            washington_stations.station_id = weather.stn
            AND
            prcp > 0
            AND
            prcp != 99.99
    )
    AS rainy_days
FROM 
    WashingtonStations2022 AS washington_stations
ORDER BY
    rainy_days DESC
)

SELECT prcp2023.name
FROM prcp2023
JOIN prcp2022
on prcp2023.name = prcp2022.name
WHERE prcp2023.rainy_days > 150
AND prcp2023.rainy_days < prcp2022.rainy_days