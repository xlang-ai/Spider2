SELECT
  CONCAT("city", ', ', "state_name") AS "city",
  "zip_code",
  COUNT("event_id") AS "count_storms"
FROM (
    SELECT *
    FROM NOAA_DATA_PLUS.noaa_historic_severe_storms.storms_2014
    UNION ALL
    SELECT *
    FROM NOAA_DATA_PLUS.noaa_historic_severe_storms.storms_2015
    UNION ALL
    SELECT *
    FROM NOAA_DATA_PLUS.noaa_historic_severe_storms.storms_2016
    UNION ALL
    SELECT *
    FROM NOAA_DATA_PLUS.noaa_historic_severe_storms.storms_2017
    UNION ALL
    SELECT *
    FROM NOAA_DATA_PLUS.noaa_historic_severe_storms.storms_2018
    UNION ALL
    SELECT *
    FROM NOAA_DATA_PLUS.noaa_historic_severe_storms.storms_2019
    UNION ALL
    SELECT *
    FROM NOAA_DATA_PLUS.noaa_historic_severe_storms.storms_2020
    UNION ALL
    SELECT *
    FROM NOAA_DATA_PLUS.noaa_historic_severe_storms.storms_2021
    UNION ALL
    SELECT *
    FROM NOAA_DATA_PLUS.noaa_historic_severe_storms.storms_2022
    UNION ALL
    SELECT *
    FROM NOAA_DATA_PLUS.noaa_historic_severe_storms.storms_2023
    UNION ALL
    SELECT *
    FROM NOAA_DATA_PLUS.noaa_historic_severe_storms.storms_2024
) AS storms
JOIN geo_us_boundaries.zip_codes ON ST_WITHIN(ST_GEOGFROMWKB(storms."event_point"), ST_GEOGFROMWKB("zip_code_geom"))
WHERE
   LOWER(storms."event_type") = 'hail'
GROUP BY
  "zip_code", 
  "city", 
  "state_name"
ORDER BY
  "count_storms" DESC
LIMIT 5;
