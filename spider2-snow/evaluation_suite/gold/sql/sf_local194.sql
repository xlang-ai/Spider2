-- Assumptions / Reasoning:
-- 1. "Revenue" is interpreted as the total rental payment amount for a film (as in the probes that joined PAYMENT).
-- 2. "Top three revenue-generating films" for an actor are determined by the film’s total revenue (not the actor’s share).
-- 3. The actor’s share in a film is the film’s total revenue divided equally by the number of actors in that film.
-- 4. For each actor we output up to three rows (one per film) plus, on every row, the average of the actor-share across those top films.
-- 5. Actors with fewer than three films will return whatever number (<3) they have.

WITH "film_revenue" AS (
    -- total revenue per film
    SELECT
        f."film_id",
        f."title"                       AS "film_title",
        SUM(p."amount")                 AS "total_revenue"
    FROM "SQLITE_SAKILA"."SQLITE_SAKILA"."FILM"       f
    JOIN "SQLITE_SAKILA"."SQLITE_SAKILA"."INVENTORY"  i  ON f."film_id" = i."film_id"
    JOIN "SQLITE_SAKILA"."SQLITE_SAKILA"."RENTAL"     r  ON i."inventory_id" = r."inventory_id"
    JOIN "SQLITE_SAKILA"."SQLITE_SAKILA"."PAYMENT"    p  ON r."rental_id"   = p."rental_id"
    GROUP BY f."film_id", f."title"
),
"film_actor_cnt" AS (
    -- number of actors in each film
    SELECT
        fa."film_id",
        COUNT(DISTINCT fa."actor_id")   AS "actor_count"
    FROM "SQLITE_SAKILA"."SQLITE_SAKILA"."FILM_ACTOR" fa
    GROUP BY fa."film_id"
),
"film_stats" AS (
    -- combine revenue and actor count, compute per-actor share
    SELECT
        fr."film_id",
        fr."film_title",
        fr."total_revenue",
        fac."actor_count",
        fr."total_revenue" / fac."actor_count" AS "revenue_per_actor"
    FROM "film_revenue"   fr
    JOIN "film_actor_cnt" fac ON fr."film_id" = fac."film_id"
),
"actor_film" AS (
    -- link each actor to films with their share, rank films by total revenue within each actor
    SELECT
        a."actor_id",
        a."first_name",
        a."last_name",
        fs."film_id",
        fs."film_title",
        fs."total_revenue",
        fs."revenue_per_actor",
        ROW_NUMBER() OVER (
            PARTITION BY a."actor_id" 
            ORDER BY fs."total_revenue" DESC, fs."film_id" ASC) AS "film_rank"
    FROM "SQLITE_SAKILA"."SQLITE_SAKILA"."ACTOR"      a
    JOIN "SQLITE_SAKILA"."SQLITE_SAKILA"."FILM_ACTOR" fa ON a."actor_id" = fa."actor_id"
    JOIN "film_stats"                           fs ON fa."film_id" = fs."film_id"
),
"top3" AS (
    -- keep only the top 3 films per actor
    SELECT *
    FROM "actor_film"
    WHERE "film_rank" <= 3
)
SELECT
    "actor_id",
    "first_name",
    "last_name",
    "film_title",
    "total_revenue",
    "revenue_per_actor"                     AS "actor_share_in_film",
    AVG("revenue_per_actor") OVER (
        PARTITION BY "actor_id"
    )                                        AS "avg_revenue_per_actor_top3"
FROM "top3"
ORDER BY "actor_id", "film_rank";