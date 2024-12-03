WITH timestamps AS
(   
    SELECT
        DATE_TRUNC(year,DATEADD(year,-1,DATE '2024-08-29')) AS ref_timestamp,
        LAST_DAY(DATEADD(week,2 + CAST(WEEKISO(ref_timestamp) != 1 AS INTEGER),ref_timestamp),week) AS end_week,
        DATEADD(day, day_num - 7, end_week) AS date_valid_std
    FROM
    (   
        SELECT
            ROW_NUMBER() OVER (ORDER BY SEQ1()) AS day_num
        FROM
            TABLE(GENERATOR(rowcount => 7))
    ) 
)
SELECT
    country,
    postal_code,
    date_valid_std,
    tot_snowfall_in 
FROM 
    GLOBAL_WEATHER__CLIMATE_DATA_FOR_BI.standard_tile.history_day
NATURAL INNER JOIN
    timestamps
WHERE
    country='US' AND
    tot_snowfall_in > 6.0 
ORDER BY 
    postal_code,date_valid_std
;