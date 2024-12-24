WITH 
    ACTORS_SALES AS (
        SELECT 
            a."actor_id",
            a."first_name",
            a."last_name",
            SUM(p."amount") AS gross_sales
        FROM 
            SQLITE_SAKILA.SQLITE_SAKILA.ACTOR a
        JOIN 
            SQLITE_SAKILA.SQLITE_SAKILA.FILM_ACTOR fa ON fa."actor_id" = a."actor_id"
        JOIN 
            SQLITE_SAKILA.SQLITE_SAKILA.FILM f ON f."film_id" = fa."film_id"
        JOIN 
            SQLITE_SAKILA.SQLITE_SAKILA.INVENTORY i ON i."film_id" = f."film_id"
        JOIN 
            SQLITE_SAKILA.SQLITE_SAKILA.RENTAL r ON r."inventory_id" = i."inventory_id"
        JOIN 
            SQLITE_SAKILA.SQLITE_SAKILA.PAYMENT p ON p."rental_id" = r."rental_id"
        GROUP BY 
            a."actor_id", a."first_name", a."last_name"
    ),
    TOP5 AS (
        SELECT 
            "actor_id",
            CONCAT(a."first_name", ' ', a."last_name") AS full_name,
            gross_sales
        FROM 
            ACTORS_SALES a
        ORDER BY 
            gross_sales DESC
        LIMIT 
            5
    ),
    TOP_MOVIES AS (
        SELECT 
            f."film_id",
            f."title"
        FROM 
            TOP5 t5
        JOIN 
            SQLITE_SAKILA.SQLITE_SAKILA.FILM_ACTOR fa ON fa."actor_id" = t5."actor_id"
        JOIN 
            SQLITE_SAKILA.SQLITE_SAKILA.FILM f ON f."film_id" = fa."film_id"
        GROUP BY 
            f."film_id", f."title"   -- Add title to the GROUP BY clause
    ),
    CUSTOMER_RENTALS AS (
        SELECT 
            c."customer_id",
            i."film_id"
        FROM 
            SQLITE_SAKILA.SQLITE_SAKILA.CUSTOMER c
        JOIN 
            SQLITE_SAKILA.SQLITE_SAKILA.PAYMENT p ON p."customer_id" = c."customer_id"
        JOIN 
            SQLITE_SAKILA.SQLITE_SAKILA.RENTAL r ON r."rental_id" = p."rental_id"
        JOIN 
            SQLITE_SAKILA.SQLITE_SAKILA.INVENTORY i ON i."inventory_id" = r."inventory_id"
    ),
    CUSTOMER_TOP_MOVIES AS (
        SELECT DISTINCT 
            cr."customer_id"
        FROM 
            CUSTOMER_RENTALS cr
        WHERE 
            cr."film_id" IN (
                SELECT 
                    tm."film_id"
                FROM 
                    TOP_MOVIES tm
            )
    )
SELECT 
    ROUND(
        100.0 * (SELECT COUNT("customer_id") FROM CUSTOMER_TOP_MOVIES) / 
        (SELECT COUNT("customer_id") FROM SQLITE_SAKILA.SQLITE_SAKILA.CUSTOMER), 2
    ) AS answer;
