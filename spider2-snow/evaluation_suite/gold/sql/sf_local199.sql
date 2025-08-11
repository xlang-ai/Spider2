WITH result_table AS (
  SELECT 
    EXTRACT(YEAR FROM TO_TIMESTAMP("rental_date", 'YYYY-MM-DD HH24:MI:SS.FF')) AS "year", 
    EXTRACT(MONTH FROM TO_TIMESTAMP("rental_date", 'YYYY-MM-DD HH24:MI:SS.FF')) AS "rental_month", 
    "st"."store_id", 
    COUNT("re"."rental_id") AS "count"
  FROM 
    SQLITE_SAKILA.SQLITE_SAKILA.RENTAL "re"
    JOIN SQLITE_SAKILA.SQLITE_SAKILA.STAFF "st" 
      ON "re"."staff_id" = "st"."staff_id"
  GROUP BY 
    EXTRACT(YEAR FROM TO_TIMESTAMP("re"."rental_date", 'YYYY-MM-DD HH24:MI:SS.FF')),
    EXTRACT(MONTH FROM TO_TIMESTAMP("re"."rental_date", 'YYYY-MM-DD HH24:MI:SS.FF')),
    "st"."store_id"
), 
monthly_sales AS (
  SELECT 
    "year", 
    "rental_month", 
    "store_id", 
    SUM("count") AS "total_rentals"
  FROM 
    result_table
  GROUP BY 
    "year", 
    "rental_month", 
    "store_id"
),
store_max_sales AS (
  SELECT 
    "store_id", 
    "year", 
    "rental_month", 
    "total_rentals", 
    MAX("total_rentals") OVER (PARTITION BY "store_id") AS "max_rentals"
  FROM 
    monthly_sales
)
SELECT 
  "store_id", 
  "year", 
  "rental_month", 
  "total_rentals"
FROM 
  store_max_sales
WHERE 
  "total_rentals" = "max_rentals"
ORDER BY 
  "store_id";
