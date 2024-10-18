WITH patents_sample AS (               -- name of our table
SELECT 
  t1.publication_number, 
  t1.application_number 
FROM 
  spider2-public-data.patents.publications t1 
WHERE         
 country_code = 'CN'       
 AND
  grant_date between 20100101 AND 20231231  
),

family_number AS (
SELECT
  t1.publication_number,
  COUNT(DISTINCT t3.application_number) AS family_size,
FROM
  patents_sample t1
LEFT JOIN
  spider2-public-data.patents.publications t2
ON
  t1.publication_number = t2.publication_number
LEFT JOIN
  spider2-public-data.patents.publications t3
ON
  t2.family_id = t3.family_id
GROUP BY
  t1.publication_number
)

SELECT COUNT(*) FROM family_number WHERE family_size>1