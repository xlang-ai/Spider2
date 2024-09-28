WITH weekend_accidents AS (
    SELECT
        state_name,
        CASE
            WHEN atmospheric_conditions_1_name = 'Rain' THEN 'Rain'
            WHEN atmospheric_conditions_1_name = 'Clear' THEN 'Clear'
            ELSE 'Other'
        END AS Weather_Condition,
        COUNT(DISTINCT consecutive_number) AS num_accidents
    FROM
        `bigquery-public-data.nhtsa_traffic_fatalities.accident_2016`
    WHERE
        EXTRACT(DAYOFWEEK FROM timestamp_of_crash) IN (1, 7)  -- 1 = Sunday, 7 = Saturday
        AND atmospheric_conditions_1_name IN ('Rain', 'Clear')
    GROUP BY
        state_name, Weather_Condition
),

weather_difference AS (
    SELECT
        state_name,
        MAX(CASE WHEN Weather_Condition = 'Rain' THEN num_accidents ELSE 0 END) AS Rain_Accidents,
        MAX(CASE WHEN Weather_Condition = 'Clear' THEN num_accidents ELSE 0 END) AS Clear_Accidents,
        ABS(MAX(CASE WHEN Weather_Condition = 'Rain' THEN num_accidents ELSE 0 END) -
            MAX(CASE WHEN Weather_Condition = 'Clear' THEN num_accidents ELSE 0 END)) AS Difference
    FROM
        weekend_accidents
    GROUP BY
        state_name
)

SELECT
    state_name,
    Difference
FROM
    weather_difference
ORDER BY
    Difference DESC
LIMIT 3;