WITH interim_table as(
SELECT 
    t1."publication_number", 
    SUBSTR(ipc_u.value:"code", 0, 4) as ipc4
FROM 
    PATENTS.PATENTS.PUBLICATIONS t1,
    LATERAL FLATTEN(input => t1."ipc") AS ipc_u
WHERE
"country_code" = 'US'  
AND "grant_date" between 20220601 AND 20220831
  AND "grant_date" != 0
  AND "publication_number" LIKE '%B2%'  
GROUP BY 
    t1."publication_number", 
    ipc4
) 
SELECT 
ipc4
FROM 
interim_table 
GROUP BY ipc4
ORDER BY COUNT("publication_number") DESC
LIMIT 1