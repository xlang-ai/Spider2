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
),
DISTANCES AS (
    SELECT
        "flight_id",
        "from_city",
        "to_city",
        CASE
            WHEN "from_city" < "to_city" THEN "from_city" ELSE "to_city" END AS "city1",
        CASE
            WHEN "from_city" < "to_city" THEN "to_city" ELSE "from_city" END AS "city2",
        2 * 6371 * ASIN(SQRT(
            POWER(SIN(RADIANS(("to_latitude" - "from_latitude") / 2)), 2) +
            COS(RADIANS("from_latitude")) * COS(RADIANS("to_latitude")) *
            POWER(SIN(RADIANS(("to_longitude" - "from_longitude") / 2)), 2)
        )) AS "distance_km"
    FROM FLIGHT_INFO
),
ALL_Route AS (
    SELECT
        "city1",
        "city2",
        "distance_km",
        COUNT(*) AS "number_of_flights" -- Count flights for both directions
    FROM DISTANCES
    WHERE ("city1" = 'Abakan' OR "city2" = 'Abakan')
    GROUP BY "city1", "city2", "distance_km"
)
SELECT 
    "distance_km"
FROM ALL_Route
ORDER BY "distance_km" DESC
LIMIT 1;