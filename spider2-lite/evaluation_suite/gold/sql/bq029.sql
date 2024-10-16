SELECT 
  AVG(num_inventors) AS avg_inventors,
  COUNT(*) AS cnt,
  filing_year
FROM (
  SELECT 
    ANY_VALUE(ARRAY_LENGTH(inventor)) AS num_inventors,
    ANY_VALUE(country_code) AS country_code,
    ANY_VALUE(CAST(FLOOR(filing_date / (5 * 10000)) AS INT64)) * 5 AS filing_year
  FROM 
    `spider2-public-data.patents.publications` AS pubs
  WHERE 
    filing_date > 19450000 
    AND filing_date < 20200000
    AND ARRAY_LENGTH(inventor) > 0
  GROUP BY 
    publication_number
)
WHERE country_code in ('US')
GROUP BY 
  filing_year, 
  country_code
ORDER BY 
  filing_year;