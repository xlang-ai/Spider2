WITH homeless_2012 AS (
  SELECT Homeless_Veterans AS Vet12, CoC_Name  
  FROM `bigquery-public-data.sdoh_hud_pit_homelessness.hud_pit_by_coc` 
  WHERE SUBSTR(CoC_Number,0,2) = "NY" AND Count_Year = 2012
),
 
homeless_2018 AS (
  SELECT Homeless_Veterans AS Vet18, CoC_Name  
  FROM `bigquery-public-data.sdoh_hud_pit_homelessness.hud_pit_by_coc` 
  WHERE SUBSTR(CoC_Number,0,2) = "NY" AND Count_Year = 2018
),
 
veterans_change AS (
  SELECT homeless_2012.COC_Name, Vet12, Vet18, Vet18 - Vet12 AS VetChange
  FROM homeless_2018
  JOIN homeless_2012
  ON homeless_2018.CoC_Name = homeless_2012.CoC_Name
)

SELECT COC_Name, VetChange FROM veterans_change
ORDER BY CoC_Name;