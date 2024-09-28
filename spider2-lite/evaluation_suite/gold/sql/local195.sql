WITH
    actors_sales AS (
        SELECT 
            a.actor_id,
            a.first_name,
            a.last_name,
            SUM(p.amount) OVER (PARTITION BY a.actor_id) AS gross_sales,
            ROW_NUMBER() OVER (PARTITION BY a.actor_id) AS row_num
        FROM 
            actor a
        JOIN 
            film_actor fa ON fa.actor_id = a.actor_id
        JOIN 
            film f ON f.film_id = fa.film_id
        JOIN 
            inventory i ON i.film_id = f.film_id
        JOIN 
            rental r ON r.inventory_id = i.inventory_id
        JOIN 
            payment p ON p.rental_id = r.rental_id
        ORDER BY 
            a.actor_id, row_num
    ),
    top5 AS (
        SELECT 
            actor_id,
            first_name || ' ' || last_name AS full_name,
            gross_sales
        FROM 
            actors_sales
        WHERE 
            row_num = 1
        ORDER BY 
            gross_sales DESC
        LIMIT 
            5
    ),
    top_movies AS (
        SELECT 
            f.film_id,
            f.title
        FROM 
            top5 t5
        JOIN 
            film_actor fa ON fa.actor_id = t5.actor_id
        JOIN 
            film f ON f.film_id = fa.film_id
        GROUP BY 
            f.film_id
    ),
    customer_rentals AS (
        SELECT 
            c.customer_id,
            i.film_id
        FROM 
            customer c
        JOIN 
            payment p ON p.customer_id = c.customer_id
        JOIN 
            rental r ON r.rental_id = p.rental_id
        JOIN 
            inventory i ON i.inventory_id = r.inventory_id
        ORDER BY 
            c.customer_id
    ),
    customer_top_movies AS (
        SELECT DISTINCT 
            cr.customer_id
        FROM 
            customer_rentals cr
        WHERE 
            cr.film_id IN (
                SELECT 
                    tm.film_id
                FROM 
                    top_movies tm
            )
    )
SELECT 
    ROUND(100.0 * (SELECT COUNT(customer_id) FROM customer_top_movies) / (SELECT COUNT(customer_id) FROM customer), 2) AS answer;
