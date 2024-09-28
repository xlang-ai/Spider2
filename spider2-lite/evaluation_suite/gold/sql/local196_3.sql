WITH result_table AS (
  SELECT 
    strftime('%Y', RE.RENTAL_DATE) AS YEAR, 
    strftime('%m', RE.RENTAL_DATE) AS RENTAL_MONTH, 
    ST.STORE_ID, 
    COUNT(RE.RENTAL_ID) AS count 
  FROM 
    RENTAL RE 
    JOIN STAFF ST ON RE.STAFF_ID = ST.STAFF_ID 
  GROUP BY 
    YEAR, 
    RENTAL_MONTH, 
    ST.STORE_ID 
), 
monthly_sales AS (
  SELECT 
    YEAR, 
    RENTAL_MONTH, 
    STORE_ID, 
    SUM(count) AS total_rentals 
  FROM 
    result_table 
  GROUP BY 
    YEAR, 
    RENTAL_MONTH, 
    STORE_ID
),
store_max_sales AS (
  SELECT 
    STORE_ID, 
    YEAR, 
    RENTAL_MONTH, 
    total_rentals, 
    MAX(total_rentals) OVER (PARTITION BY STORE_ID) AS max_rentals 
  FROM 
    monthly_sales
)
SELECT 
  STORE_ID, 
  YEAR, 
  RENTAL_MONTH, 
  total_rentals 
FROM 
  store_max_sales 
WHERE 
  total_rentals = max_rentals
ORDER BY 
  STORE_ID;
