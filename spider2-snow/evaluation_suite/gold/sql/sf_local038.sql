SELECT
    ACTOR."first_name" || ' ' || ACTOR."last_name" AS "full_name"
FROM
    PAGILA.PAGILA.ACTOR
INNER JOIN PAGILA.PAGILA.FILM_ACTOR ON ACTOR."actor_id" = FILM_ACTOR."actor_id"
INNER JOIN PAGILA.PAGILA.FILM ON FILM_ACTOR."film_id" = FILM."film_id"
INNER JOIN PAGILA.PAGILA.FILM_CATEGORY ON FILM."film_id" = FILM_CATEGORY."film_id"
INNER JOIN PAGILA.PAGILA.CATEGORY ON FILM_CATEGORY."category_id" = CATEGORY."category_id"
-- Join with the language table
INNER JOIN PAGILA.PAGILA.LANGUAGE ON FILM."language_id" = LANGUAGE."language_id"
WHERE
    CATEGORY."name" = 'Children' AND
    FILM."release_year" BETWEEN 2000 AND 2010 AND
    FILM."rating" IN ('G', 'PG') AND
    LANGUAGE."name" = 'English' AND
    FILM."length" <= 120
GROUP BY
    ACTOR."actor_id", ACTOR."first_name", ACTOR."last_name"
ORDER BY
    COUNT(FILM."film_id") DESC
LIMIT 1;