WITH homeless_2015 AS (
  SELECT Unsheltered_Homeless AS U15, SUBSTR(CoC_Number, 0, 2) as State_Abbr
  FROM `bigquery-public-data.sdoh_hud_pit_homelessness.hud_pit_by_coc`
  WHERE Count_Year = 2015
),
 
homeless_2018 AS (
  SELECT Unsheltered_Homeless AS U18, SUBSTR(CoC_Number, 0, 2) as State_Abbr
  FROM `bigquery-public-data.sdoh_hud_pit_homelessness.hud_pit_by_coc`
  WHERE Count_Year = 2018
),

unsheltered_change AS (
  SELECT homeless_2018.State_Abbr, 
         SUM(U15) AS Unsheltered_2015, 
         SUM(U18) AS Unsheltered_2018, 
         (SUM(U18) - SUM(U15)) / SUM(U15) * 100 AS Percent_Change
  FROM homeless_2018
  JOIN homeless_2015
  ON homeless_2018.State_Abbr = homeless_2015.State_Abbr
  GROUP BY State_Abbr
),

average_change AS (
  SELECT AVG(Percent_Change) AS Avg_Change
  FROM unsheltered_change
),

closest_to_avg AS (
  SELECT State_Abbr
  FROM unsheltered_change, average_change
  ORDER BY ABS(Percent_Change - Avg_Change)
  LIMIT 5
)

SELECT State_Abbr FROM closest_to_avg;