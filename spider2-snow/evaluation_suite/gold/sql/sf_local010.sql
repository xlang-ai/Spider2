
WITH FLIGHT_INFO AS (
    SELECT    
        FLIGHTS."flight_id",
        PARSE_JSON(DEPARTURE."city"):"en" AS "from_city",
        CAST(SUBSTR(DEPARTURE."coordinates", 2, POSITION(',' IN DEPARTURE."coordinates") - 2) AS DOUBLE) AS "from_longitude",
        CAST(SUBSTR(DEPARTURE."coordinates", POSITION(',' IN DEPARTURE."coordinates") + 1, LENGTH(DEPARTURE."coordinates") - POSITION(',' IN DEPARTURE."coordinates") - 2) AS DOUBLE) AS "from_latitude",
        PARSE_JSON(ARRIVAL."city"):"en" AS "to_city",
        CAST(SUBSTR(ARRIVAL."coordinates", 2, POSITION(',' IN ARRIVAL."coordinates") - 2) AS DOUBLE) AS "to_longitude",
        CAST(SUBSTR(ARRIVAL."coordinates", POSITION(',' IN ARRIVAL."coordinates") + 1, LENGTH(ARRIVAL."coordinates") - POSITION(',' IN ARRIVAL."coordinates") - 2) AS DOUBLE) AS "to_latitude"
    FROM
        AIRLINES.AIRLINES.FLIGHTS 
    LEFT JOIN AIRLINES.AIRLINES.AIRPORTS_DATA AS DEPARTURE ON FLIGHTS."departure_airport" = DEPARTURE."airport_code"
    LEFT JOIN AIRLINES.AIRLINES.AIRPORTS_DATA AS ARRIVAL ON FLIGHTS."arrival_airport" = ARRIVAL."airport_code"
)
-- Create a histogram distribution of average_distance_km
SELECT "group_count" FROM
(
    SELECT
        FLOOR("average_distance_km" / 1000) * 1000 AS "distance_range",
        COUNT(*) AS "group_count"
    FROM (
        -- Calculate the average distance for each unique combination of from_city and to_city
        SELECT
            "from_city",
            "to_city",
            AVG("distance_km") AS "average_distance_km"
        FROM (
            -- Subquery to calculate the distances as before
            SELECT
                "from_city",
                "to_city",
                -- Calculate the distance using the Haversine formula
                2 * 6371 * ASIN(SQRT(
                    POWER(SIN(RADIANS(("to_latitude" - "from_latitude") / 2)), 2) +
                    COS(RADIANS("from_latitude")) * COS(RADIANS("to_latitude")) *
                    POWER(SIN(RADIANS(("to_longitude" - "from_longitude") / 2)), 2)
                )) AS "distance_km"
            FROM FLIGHT_INFO
        ) AS subquery
        GROUP BY "from_city", "to_city"
    ) AS distances
    GROUP BY "distance_range"
    ORDER BY "group_count"
    LIMIT 1
)