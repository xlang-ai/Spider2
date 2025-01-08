SELECT
    category.name
FROM
    category
INNER JOIN film_category USING (category_id)
INNER JOIN film USING (film_id)
INNER JOIN inventory USING (film_id)
INNER JOIN rental USING (inventory_id)
INNER JOIN customer USING (customer_id)
INNER JOIN address USING (address_id)
INNER JOIN city USING (city_id)
WHERE
    LOWER(city.city) LIKE 'a%' OR city.city LIKE '%-%'
GROUP BY
    category.name
ORDER BY
    SUM(CAST((julianday(rental.return_date) - julianday(rental.rental_date)) * 24 AS INTEGER)) DESC
LIMIT
    1;