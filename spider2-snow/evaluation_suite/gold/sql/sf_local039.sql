SELECT
  c."name" AS category_name,
  SUM(DATEDIFF('second', TRY_TO_TIMESTAMP_NTZ(r."rental_date"), TRY_TO_TIMESTAMP_NTZ(r."return_date")))/3600.0 AS total_rental_hours
FROM "PAGILA"."PAGILA"."RENTAL" r
JOIN "PAGILA"."PAGILA"."INVENTORY" i ON r."inventory_id" = i."inventory_id"
JOIN "PAGILA"."PAGILA"."FILM_CATEGORY" fc ON i."film_id" = fc."film_id"
JOIN "PAGILA"."PAGILA"."CATEGORY" c ON fc."category_id" = c."category_id"
JOIN "PAGILA"."PAGILA"."CUSTOMER" cu ON r."customer_id" = cu."customer_id"
JOIN "PAGILA"."PAGILA"."ADDRESS" a ON cu."address_id" = a."address_id"
JOIN "PAGILA"."PAGILA"."CITY" ci ON a."city_id" = ci."city_id"
WHERE TRY_TO_TIMESTAMP_NTZ(r."rental_date") IS NOT NULL
  AND TRY_TO_TIMESTAMP_NTZ(r."return_date") IS NOT NULL
  AND (ci."city" ILIKE 'A%' OR ci."city" ILIKE '%-%')
GROUP BY c."category_id", c."name"
ORDER BY total_rental_hours DESC
LIMIT 1;