WITH 
    ACTOR_COUNT AS (
        SELECT 
            f."film_id",
            f."title",
            COUNT(fa."actor_id") AS num_actors
        FROM 
            SQLITE_SAKILA.SQLITE_SAKILA.FILM f
        JOIN 
            SQLITE_SAKILA.SQLITE_SAKILA.FILM_ACTOR fa ON fa."film_id" = f."film_id"
        GROUP BY 
            f."film_id", f."title"
        ORDER BY 
            f."film_id"
    ),
    FILM_REVENUE AS (
        SELECT 
            i."film_id",
            SUM(p."amount") AS gross_revenue
        FROM 
            SQLITE_SAKILA.SQLITE_SAKILA.PAYMENT p
        JOIN 
            SQLITE_SAKILA.SQLITE_SAKILA.RENTAL r ON r."rental_id" = p."rental_id"
        JOIN 
            SQLITE_SAKILA.SQLITE_SAKILA.INVENTORY i ON i."inventory_id" = r."inventory_id"
        GROUP BY 
            i."film_id"
        ORDER BY 
            i."film_id"
    ),
    FILM_REV_PER_ACTOR AS (
        SELECT 
            ac."title",
            fr.gross_revenue / ac.num_actors * 1.0 AS rev_per_actor
        FROM 
            ACTOR_COUNT ac
        JOIN 
            FILM_REVENUE fr ON fr."film_id" = ac."film_id"
    )
SELECT 
    *
FROM 
    FILM_REV_PER_ACTOR
ORDER BY 
    rev_per_actor DESC
FETCH FIRST 3 ROWS ONLY;
