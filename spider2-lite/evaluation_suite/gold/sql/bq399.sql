WITH country_data AS ( 
  SELECT 
    country_code, 
    short_name AS country,
    region, 
    income_group 
  FROM 
    bigquery-public-data.world_bank_wdi.country_summary
)
, birth_rate_data AS (
  SELECT 
    data.country_code, 
    country_data.country,
    country_data.region,
    AVG(value) AS avg_birth_rate
  FROM 
    bigquery-public-data.world_bank_wdi.indicators_data data 
  LEFT JOIN 
    country_data 
  ON 
    data.country_code = country_data.country_code
  WHERE 
    indicator_code = "SP.DYN.CBRT.IN" -- Birth Rate
    AND EXTRACT(YEAR FROM PARSE_DATE('%Y', CAST(year AS STRING))) BETWEEN 1980 AND 1989 -- 1980s
    AND country_data.income_group = "High income" -- High-income group
  GROUP BY 
    data.country_code, 
    country_data.country,
    country_data.region
)
, ranked_birth_rates AS (
  SELECT
    region,
    country,
    avg_birth_rate,
    RANK() OVER(PARTITION BY region ORDER BY avg_birth_rate DESC) AS rank
  FROM
    birth_rate_data
)
SELECT 
  region, 
  country, 
  avg_birth_rate
FROM 
  ranked_birth_rates
WHERE 
  rank = 1
ORDER BY 
  region;