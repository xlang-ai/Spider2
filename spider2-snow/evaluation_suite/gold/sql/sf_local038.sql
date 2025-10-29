SELECT CONCAT("a"."first_name", ' ', "a"."last_name") AS "actor_full_name"
FROM "PAGILA"."PAGILA"."FILM" AS "f"
JOIN "PAGILA"."PAGILA"."LANGUAGE" AS "l" ON "f"."language_id" = "l"."language_id"
JOIN "PAGILA"."PAGILA"."FILM_CATEGORY" AS "fc" ON "fc"."film_id" = "f"."film_id"
JOIN "PAGILA"."PAGILA"."CATEGORY" AS "c" ON "c"."category_id" = "fc"."category_id"
JOIN "PAGILA"."PAGILA"."FILM_ACTOR" AS "fa" ON "fa"."film_id" = "f"."film_id"
JOIN "PAGILA"."PAGILA"."ACTOR" AS "a" ON "a"."actor_id" = "fa"."actor_id"
WHERE UPPER("c"."name") = 'CHILDREN'
  AND UPPER("l"."name") = 'ENGLISH'
  AND "f"."rating" IN ('G', 'PG')
  AND "f"."length" <= 120
  AND TRY_TO_NUMBER("f"."release_year") BETWEEN 2000 AND 2010
GROUP BY 1
ORDER BY COUNT(DISTINCT "f"."film_id") DESC, "actor_full_name"
LIMIT 1;