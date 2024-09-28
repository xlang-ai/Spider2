WITH
    pay_order AS (
        SELECT 
            p.*,
            ROW_NUMBER() OVER (PARTITION BY p.customer_id ORDER BY p.payment_date) AS p_order
        FROM 
            payment p
    ),
    first_order AS (
        SELECT 
            po.payment_id,
            po.customer_id,
            po.rental_id
        FROM 
            pay_order po
        WHERE 
            po.p_order = 1
    ),
    first_rating AS (
        SELECT 
            fo.customer_id,
            f.film_id,
            f.title,
            f.rating
        FROM 
            first_order fo
        JOIN 
            rental r ON r.rental_id = fo.rental_id
        JOIN 
            inventory i ON i.inventory_id = r.inventory_id
        JOIN 
            film f ON f.film_id = i.film_id
    ),
    total_spending AS (
        SELECT 
            p.customer_id,
            SUM(p.amount) AS total_spend,
            COUNT(p.payment_id) - 1 AS subsequent_rentals
        FROM 
            payment p
        GROUP BY 
            p.customer_id
    )
SELECT 
    fr.rating,
    ROUND(AVG(ts.total_spend), 2) AS avg_spend,
    ROUND(AVG(ts.subsequent_rentals), 2) AS avg_subsequent_rentals_number
FROM 
    first_rating fr
JOIN 
    total_spending ts ON ts.customer_id = fr.customer_id
GROUP BY 
    fr.rating
ORDER BY 
    avg_spend DESC;
