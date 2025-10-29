WITH rentals_with_store AS (
  SELECT
    s."store_id" AS "store_id",
    TRY_TO_TIMESTAMP(r."rental_date") AS "rental_ts"
  FROM "SQLITE_SAKILA"."SQLITE_SAKILA"."RENTAL" r
  JOIN "SQLITE_SAKILA"."SQLITE_SAKILA"."STAFF" s
    ON r."staff_id" = s."staff_id"
  WHERE TRY_TO_TIMESTAMP(r."rental_date") IS NOT NULL
),
monthly_counts AS (
  SELECT
    "store_id",
    EXTRACT(YEAR FROM "rental_ts") AS "year",
    EXTRACT(MONTH FROM "rental_ts") AS "month",
    COUNT(*) AS "total_rentals"
  FROM rentals_with_store
  GROUP BY "store_id", "year", "month"
)
SELECT
  "store_id",
  "year",
  "month",
  "total_rentals"
FROM monthly_counts
QUALIFY DENSE_RANK() OVER (
  PARTITION BY "store_id"
  ORDER BY "total_rentals" DESC
) = 1
ORDER BY "store_id", "year", "month"