WITH TopActors AS (
    SELECT
        "actor_id"
    FROM "SQLITE_SAKILA"."SQLITE_SAKILA"."FILM_ACTOR"
    GROUP BY
        "actor_id"
    ORDER BY
        COUNT("film_id") DESC
    LIMIT 5
),
CustomersWithTopActorFilms AS (
    SELECT DISTINCT
        R."customer_id"
    FROM "SQLITE_SAKILA"."SQLITE_SAKILA"."RENTAL" AS R
    JOIN "SQLITE_SAKILA"."SQLITE_SAKILA"."INVENTORY" AS I
        ON R."inventory_id" = I."inventory_id"
    JOIN "SQLITE_SAKILA"."SQLITE_SAKILA"."FILM_ACTOR" AS FA
        ON I."film_id" = FA."film_id"
    WHERE
        FA."actor_id" IN (SELECT "actor_id" FROM TopActors)
)
SELECT
    (
        SELECT
            COUNT("customer_id")
        FROM CustomersWithTopActorFilms
    ) * 100.0 / (
        SELECT
            COUNT("customer_id")
        FROM "SQLITE_SAKILA"."SQLITE_SAKILA"."CUSTOMER"
    ) AS PercentageOfCustomers;