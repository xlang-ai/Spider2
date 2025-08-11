SELECT
    actor.first_name || ' ' || actor.last_name AS full_name
FROM
    actor
INNER JOIN film_actor ON actor.actor_id = film_actor.actor_id
INNER JOIN film ON film_actor.film_id = film.film_id
INNER JOIN film_category ON film.film_id = film_category.film_id
INNER JOIN category ON film_category.category_id = category.category_id
-- Join with the language table
INNER JOIN language ON film.language_id = language.language_id
WHERE
    category.name = 'Children' AND
    film.release_year BETWEEN 2000 AND 2010 AND
    film.rating IN ('G', 'PG') AND
    language.name = 'English' AND
    film.length <= 120
GROUP BY
    actor.actor_id, actor.first_name, actor.last_name
ORDER BY
    COUNT(film.film_id) DESC
LIMIT 1;
