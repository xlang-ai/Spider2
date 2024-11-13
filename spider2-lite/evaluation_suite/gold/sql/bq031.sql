WITH transrate AS (
    SELECT
        DATE(CAST(year AS INT64), CAST(mo AS INT64), CAST(da AS INT64)) AS observation_date
        , ROUND((temp - 32.0) / 1.8, 1) AS temp_mean_c -- using Celsius instead of Fahrenheit
        , ROUND(prcp * 2.54, 1) AS prcp_cm -- from inches to centimeters
        , ROUND(CAST(wdsp AS FLOAT64) * 1.852 / 3.6, 1) AS wdsp_ms -- from knots to meters per second
    FROM `bigquery-public-data.noaa_gsod.gsod*`
    WHERE _TABLE_SUFFIX = "2019"
        AND CAST(mo AS INT64) <= 3
        AND stn in (SELECT usaf FROM `bigquery-public-data.noaa_gsod.stations` WHERE name = "ROCHESTER")
),

moving_avg AS (
    SELECT
        observation_date
        , temp_mean_c
        , prcp_cm
        , wdsp_ms
        , AVG(temp_mean_c) OVER (ORDER BY observation_date ROWS 7 PRECEDING) AS temp_moving_avg
        , AVG(prcp_cm) OVER (ORDER BY observation_date ROWS 7 PRECEDING) AS prcp_moving_avg
        , AVG(wdsp_ms) OVER (ORDER BY observation_date ROWS 7 PRECEDING) AS wdsp_moving_avg
    FROM transrate
),

lag_moving_avg AS (
    SELECT
        observation_date
        , temp_mean_c
        , prcp_cm
        , wdsp_ms
        , LAG(temp_moving_avg, 1) OVER (ORDER BY observation_date) AS lag1_temp_moving_avg
        , LAG(prcp_moving_avg, 1) OVER (ORDER BY observation_date) AS lag1_prcp_moving_avg
        , LAG(wdsp_moving_avg, 1) OVER (ORDER BY observation_date) AS lag1_wdsp_moving_avg

        , LAG(temp_moving_avg, 2) OVER (ORDER BY observation_date) AS lag2_temp_moving_avg
        , LAG(prcp_moving_avg, 2) OVER (ORDER BY observation_date) AS lag2_prcp_moving_avg
        , LAG(wdsp_moving_avg, 2) OVER (ORDER BY observation_date) AS lag2_wdsp_moving_avg

        , LAG(temp_moving_avg, 3) OVER (ORDER BY observation_date) AS lag3_temp_moving_avg
        , LAG(prcp_moving_avg, 3) OVER (ORDER BY observation_date) AS lag3_prcp_moving_avg
        , LAG(wdsp_moving_avg, 3) OVER (ORDER BY observation_date) AS lag3_wdsp_moving_avg

        , LAG(temp_moving_avg, 4) OVER (ORDER BY observation_date) AS lag4_temp_moving_avg
        , LAG(prcp_moving_avg, 4) OVER (ORDER BY observation_date) AS lag4_prcp_moving_avg
        , LAG(wdsp_moving_avg, 4) OVER (ORDER BY observation_date) AS lag4_wdsp_moving_avg

        , LAG(temp_moving_avg, 5) OVER (ORDER BY observation_date) AS lag5_temp_moving_avg
        , LAG(prcp_moving_avg, 5) OVER (ORDER BY observation_date) AS lag5_prcp_moving_avg
        , LAG(wdsp_moving_avg, 5) OVER (ORDER BY observation_date) AS lag5_wdsp_moving_avg

        , LAG(temp_moving_avg, 6) OVER (ORDER BY observation_date) AS lag6_temp_moving_avg
        , LAG(prcp_moving_avg, 6) OVER (ORDER BY observation_date) AS lag6_prcp_moving_avg
        , LAG(wdsp_moving_avg, 6) OVER (ORDER BY observation_date) AS lag6_wdsp_moving_avg

        , LAG(temp_moving_avg, 7) OVER (ORDER BY observation_date) AS lag7_temp_moving_avg
        , LAG(prcp_moving_avg, 7) OVER (ORDER BY observation_date) AS lag7_prcp_moving_avg
        , LAG(wdsp_moving_avg, 7) OVER (ORDER BY observation_date) AS lag7_wdsp_moving_avg

        , LAG(temp_moving_avg, 8) OVER (ORDER BY observation_date) AS lag8_temp_moving_avg
        , LAG(prcp_moving_avg, 8) OVER (ORDER BY observation_date) AS lag8_prcp_moving_avg
        , LAG(wdsp_moving_avg, 8) OVER (ORDER BY observation_date) AS lag8_wdsp_moving_avg
    FROM moving_avg
)

SELECT
    observation_date
    , temp_mean_c
    , prcp_cm
    , wdsp_ms

    , ROUND(lag1_temp_moving_avg, 1) AS lag1_temp_moving_avg
    , ROUND(lag1_prcp_moving_avg, 1) AS lag1_prcp_moving_avg
    , ROUND(lag1_wdsp_moving_avg, 1) AS lag1_wdsp_moving_avg
    
    , ROUND(lag1_temp_moving_avg - lag2_temp_moving_avg, 1) AS diff2_temp_moving_avg
    , ROUND(lag1_prcp_moving_avg - lag2_prcp_moving_avg, 1) AS diff2_prcp_moving_avg
    , ROUND(lag1_wdsp_moving_avg - lag2_wdsp_moving_avg, 1) AS diff2_wdsp_moving_avg
    , ROUND(lag2_temp_moving_avg, 1) AS lag2_temp_moving_avg
    , ROUND(lag2_prcp_moving_avg, 1) AS lag2_prcp_moving_avg
    , ROUND(lag2_wdsp_moving_avg, 1) AS lag2_wdsp_moving_avg
    
    , ROUND(lag2_temp_moving_avg - lag3_temp_moving_avg, 1) AS diff3_temp_moving_avg
    , ROUND(lag2_prcp_moving_avg - lag3_prcp_moving_avg, 1) AS diff3_prcp_moving_avg
    , ROUND(lag2_wdsp_moving_avg - lag3_wdsp_moving_avg, 1) AS diff3_wdsp_moving_avg
    , ROUND(lag3_temp_moving_avg, 1) AS lag3_temp_moving_avg
    , ROUND(lag3_prcp_moving_avg, 1) AS lag3_prcp_moving_avg
    , ROUND(lag3_wdsp_moving_avg, 1) AS lag3_wdsp_moving_avg
    
    , ROUND(lag3_temp_moving_avg - lag4_temp_moving_avg, 1) AS diff4_temp_moving_avg
    , ROUND(lag3_prcp_moving_avg - lag4_prcp_moving_avg, 1) AS diff4_prcp_moving_avg
    , ROUND(lag3_wdsp_moving_avg - lag4_wdsp_moving_avg, 1) AS diff4_wdsp_moving_avg
    , ROUND(lag4_temp_moving_avg, 1) AS lag4_temp_moving_avg
    , ROUND(lag4_prcp_moving_avg, 1) AS lag4_prcp_moving_avg
    , ROUND(lag4_wdsp_moving_avg, 1) AS lag4_wdsp_moving_avg
    
    , ROUND(lag4_temp_moving_avg - lag5_temp_moving_avg, 1) AS diff5_temp_moving_avg
    , ROUND(lag4_prcp_moving_avg - lag5_prcp_moving_avg, 1) AS diff5_prcp_moving_avg
    , ROUND(lag4_wdsp_moving_avg - lag5_wdsp_moving_avg, 1) AS diff5_wdsp_moving_avg
    , ROUND(lag5_temp_moving_avg, 1) AS lag5_temp_moving_avg
    , ROUND(lag5_prcp_moving_avg, 1) AS lag5_prcp_moving_avg
    , ROUND(lag5_wdsp_moving_avg, 1) AS lag5_wdsp_moving_avg
    
    , ROUND(lag5_temp_moving_avg - lag6_temp_moving_avg, 1) AS diff6_temp_moving_avg
    , ROUND(lag5_prcp_moving_avg - lag6_prcp_moving_avg, 1) AS diff6_prcp_moving_avg
    , ROUND(lag5_wdsp_moving_avg - lag6_wdsp_moving_avg, 1) AS diff6_wdsp_moving_avg
    , ROUND(lag6_temp_moving_avg, 1) AS lag6_temp_moving_avg
    , ROUND(lag6_prcp_moving_avg, 1) AS lag6_prcp_moving_avg
    , ROUND(lag6_wdsp_moving_avg, 1) AS lag6_wdsp_moving_avg
    
    , ROUND(lag6_temp_moving_avg - lag7_temp_moving_avg, 1) AS diff7_temp_moving_avg
    , ROUND(lag6_prcp_moving_avg - lag7_prcp_moving_avg, 1) AS diff7_prcp_moving_avg
    , ROUND(lag6_wdsp_moving_avg - lag7_wdsp_moving_avg, 1) AS diff7_wdsp_moving_avg
    , ROUND(lag7_temp_moving_avg, 1) AS lag7_temp_moving_avg
    , ROUND(lag7_prcp_moving_avg, 1) AS lag7_prcp_moving_avg
    , ROUND(lag7_wdsp_moving_avg, 1) AS lag7_wdsp_moving_avg
    
    , ROUND(lag7_temp_moving_avg - lag8_temp_moving_avg, 1) AS diff8_temp_moving_avg
    , ROUND(lag7_prcp_moving_avg - lag8_prcp_moving_avg, 1) AS diff8_prcp_moving_avg
    , ROUND(lag7_wdsp_moving_avg - lag8_wdsp_moving_avg, 1) AS diff8_wdsp_moving_avg
    , ROUND(lag8_temp_moving_avg, 1) AS lag8_temp_moving_avg
    , ROUND(lag8_prcp_moving_avg, 1) AS lag8_prcp_moving_avg
    , ROUND(lag8_wdsp_moving_avg, 1) AS lag8_wdsp_moving_avg
FROM lag_moving_avg
WHERE
  lag8_temp_moving_avg IS NOT NULL
ORDER BY observation_date;
-- all result rounded to 1 decimal place