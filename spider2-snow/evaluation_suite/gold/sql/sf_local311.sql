WITH LastRacePerYear AS (
    SELECT "year", MAX("race_id") AS "last_race_id"
    FROM "F1"."F1"."RACES"
    GROUP BY "year"
),
FinalConstructorStandings AS (
    SELECT
        lr."year",
        cs."constructor_id",
        cs."points" AS "constructor_points"
    FROM LastRacePerYear AS lr
    JOIN "F1"."F1"."CONSTRUCTOR_STANDINGS" AS cs
        ON lr."last_race_id" = cs."race_id"
),
FinalDriverStandings AS (
    SELECT
        lr."year",
        ds."driver_id",
        ds."points" AS "driver_points"
    FROM LastRacePerYear AS lr
    JOIN "F1"."F1"."DRIVER_STANDINGS" AS ds
        ON lr."last_race_id" = ds."race_id"
),
DriverPointsPerConstructorYear AS (
    SELECT
        r."year",
        res."constructor_id",
        res."driver_id",
        SUM(res."points") AS "points_for_constructor"
    FROM "F1"."F1"."RESULTS" AS res
    JOIN "F1"."F1"."RACES" AS r ON res."race_id" = r."race_id"
    GROUP BY r."year", res."constructor_id", res."driver_id"
),
BestDriverPerConstructorYear AS (
    SELECT
        "year",
        "constructor_id",
        "driver_id"
    FROM (
        SELECT
            "year",
            "constructor_id",
            "driver_id",
            ROW_NUMBER() OVER(PARTITION BY "year", "constructor_id" ORDER BY "points_for_constructor" DESC, "driver_id" ASC) as "rn"
        FROM DriverPointsPerConstructorYear
    )
    WHERE "rn" = 1
)
SELECT
    c."name",
    fcs."year"
FROM FinalConstructorStandings AS fcs
JOIN BestDriverPerConstructorYear AS bdpc
    ON fcs."year" = bdpc."year" AND fcs."constructor_id" = bdpc."constructor_id"
JOIN FinalDriverStandings AS fds
    ON bdpc."year" = fds."year" AND bdpc."driver_id" = fds."driver_id"
JOIN "F1"."F1"."CONSTRUCTORS" AS c
    ON fcs."constructor_id" = c."constructor_id"
ORDER BY (fcs."constructor_points" + fds."driver_points") DESC
LIMIT 3;