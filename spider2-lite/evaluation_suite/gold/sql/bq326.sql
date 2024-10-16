--Transposing data in the yearly columns to rows in a new table. 
WITH base AS (
    SELECT country,
    country_code,
    unpivotted
    FROM `bigquery-public-data.world_bank_global_population.population_by_country` a
    
  , UNNEST(fhoffa.x.unpivot(a, 'year')) unpivotted
),

pop AS (SELECT country, 
 country_code, 
--unpivot the returned data in the first CTE
 CAST (RIGHT(unpivotted.key,4) AS INT64) AS as_of_year,
 CASE WHEN unpivotted.value = 'null' THEN '0' ELSE unpivotted.value END AS population 
FROM base 
--selecting years from 2010 and beyond
WHERE CAST (RIGHT(unpivotted.key,4) AS INT64)  >= 2010 ), 
----New CTE to change population data type
pop_1 AS ( 
  SELECT 
   country,
   country_code,
   as_of_year,
  CAST (population as FLOAT64) AS population,
--using lag function to calculate previous population by country_code
  COALESCE (LAG (CAST (population AS FLOAT64), 1)
  OVER (PARTITION BY country_code ORDER BY as_of_year), 0) AS prev_population 
  from pop ), 
--New CTE to calculate change in population and filter for year 2018 
Number1 as (
  SELECT *, 
--used Coalesce to get rid of null. from division
--Used Nullif to handle error by diving by zero.
  COALESCE (ROUND ( population /NULLIF(prev_population,0), 2 ), 0) AS change_in_population  
  FROM pop_1
--filter for 2018
where pop_1.as_of_year = 2018),
--New CTE to return required columns and filter for PPP(SH.XPD.CHEX.PP.CD RETURNS PPP)
A AS (
 SELECT
  country_name,
  country_code,
  indicator_name,
  value as PPP,
  year,
--using lag function to calculate previous PPP by country_code ordered by year
 LAG(value) over (partition by country_code order by year) as prePPP
 FROM `bigquery-public-data.world_bank_health_population.health_nutrition_population`
-- filter for SH.XPD.CHEX.PP.CD
 WHERE
  indicator_code = "SH.XPD.CHEX.PP.CD"),
--CTE to calculate chane in population
B AS (
  SELECT
   *,
--used Coalesce to get rid of null. from division
--Used Nullif to handle error by diving by zero. 
  COALESCE (ROUND ( A.PPP /NULLIF(prePPP,0), 2 ), 0) AS change_in_PPP
  FROM A 
--filter for 2018
  WHERE year = 2018)
--join change in population table and change in PPP into one table based on the country code
SELECT 
 COUNT(country) AS country_count
FROM Number1
 left join B
  ON Number1.country_code = B.country_code
WHERE
 B.change_in_PPP > 1 AND Number1.change_in_population > 1;