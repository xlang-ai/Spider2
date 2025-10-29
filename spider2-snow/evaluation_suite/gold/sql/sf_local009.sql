WITH flights_abakan AS (
  SELECT
    f."flight_id",
    dep."airport_code" AS "dep_code",
    arr."airport_code" AS "arr_code",
    TRY_PARSE_JSON(dep."city"):"en"::string AS "dep_city",
    TRY_PARSE_JSON(arr."city"):"en"::string AS "arr_city",
    dep."coordinates" AS "dep_coord",
    arr."coordinates" AS "arr_coord"
  FROM "AIRLINES"."AIRLINES"."FLIGHTS" AS f
  JOIN "AIRLINES"."AIRLINES"."AIRPORTS_DATA" AS dep
    ON dep."airport_code" = f."departure_airport"
  JOIN "AIRLINES"."AIRLINES"."AIRPORTS_DATA" AS arr
    ON arr."airport_code" = f."arrival_airport"
  WHERE TRY_PARSE_JSON(dep."city"):"en"::string = 'Abakan'
     OR TRY_PARSE_JSON(arr."city"):"en"::string = 'Abakan'
),
coords AS (
  SELECT
    "flight_id",
    CAST(SPLIT_PART(REPLACE(REPLACE("dep_coord",'(',''),')',''), ',', 1) AS DOUBLE) AS "dep_lon",
    CAST(SPLIT_PART(REPLACE(REPLACE("dep_coord",'(',''),')',''), ',', 2) AS DOUBLE) AS "dep_lat",
    CAST(SPLIT_PART(REPLACE(REPLACE("arr_coord",'(',''),')',''), ',', 1) AS DOUBLE) AS "arr_lon",
    CAST(SPLIT_PART(REPLACE(REPLACE("arr_coord",'(',''),')',''), ',', 2) AS DOUBLE) AS "arr_lat"
  FROM flights_abakan
),
dist AS (
  SELECT
    "flight_id",
    6371 * 2 * ASIN(
      SQRT(
        POWER(SIN((RADIANS("arr_lat") - RADIANS("dep_lat")) / 2), 2)
        + COS(RADIANS("dep_lat")) * COS(RADIANS("arr_lat")) * POWER(SIN((RADIANS("arr_lon") - RADIANS("dep_lon")) / 2), 2)
      )
    ) AS "distance_km"
  FROM coords
)
SELECT MAX("distance_km") AS "max_distance_km"
FROM dist;