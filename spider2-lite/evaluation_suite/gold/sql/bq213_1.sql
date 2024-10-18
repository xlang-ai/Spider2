WITH interim_table as(
SELECT 
    t1.publication_number, 
    SUBSTR(ipc_u.code, 0, 4) as ipc4, 
    COUNT(
    SUBSTR(ipc_u.code, 0, 4)
    ) as ipc4_count 
FROM 
    `spider2-public-data.patents.publications` t1, 
    UNNEST(ipc) AS ipc_u 
WHERE
country_code = 'US'  
AND grant_date between 20220601 AND 20220930
  AND grant_date != 0
  AND publication_number LIKE '%B2%'  
GROUP BY 
    t1.publication_number, 
    ipc4
) 
SELECT 
publication_number, ipc4
FROM 
interim_table 
where 
concat(
    interim_table.publication_number, 
    interim_table.ipc4_count
) IN (
    SELECT 
    concat(
        publication_number, 
        MAX(ipc4_count)
    ) 
    FROM 
    interim_table 
    group by 
    publication_number
)
AND ipc4_count >= 10