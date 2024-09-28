WITH tenplus AS (
  SELECT 
    year, 
    EXTRACT(DAYOFYEAR FROM DATE(eventdate)) AS dayofyear, 
    COUNT(*) AS count
  FROM 
    bigquery-public-data.gbif.occurrences
  WHERE 
    eventdate IS NOT NULL 
    AND species = 'Sterna paradisaea' 
    AND decimallatitude > 40.0 
    AND month > 1
  GROUP BY 
    year, 
    eventdate
  HAVING 
    COUNT(*) > 10
)

SELECT 
  year AS year
FROM 
  tenplus
GROUP BY 
  year
ORDER BY 
  MIN(dayofyear)
LIMIT 1;