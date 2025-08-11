SELECT
  table_2019.avg_symptom_Anosmia_2019,
  table_2020.avg_symptom_Anosmia_2020,
  ((table_2020.avg_symptom_Anosmia_2020 - table_2019.avg_symptom_Anosmia_2019) / table_2019.avg_symptom_Anosmia_2019) * 100 AS avg_increase
FROM (
  SELECT
    AVG(SAFE_CAST(symptom_Anosmia AS FLOAT64)) AS avg_symptom_Anosmia_2020
  FROM
    `bigquery-public-data.covid19_symptom_search.symptom_search_sub_region_2_weekly`
  WHERE
    sub_region_1 = "New York"
    AND sub_region_2 IN ("Bronx County", "Queens County", "Kings County", "New York County", "Richmond County")
    AND date >= '2020-01-01'
    AND date < '2021-01-01'
) AS table_2020,
(
  SELECT
    AVG(SAFE_CAST(symptom_Anosmia AS FLOAT64)) AS avg_symptom_Anosmia_2019
  FROM
    `bigquery-public-data.covid19_symptom_search.symptom_search_sub_region_2_weekly`
  WHERE
    sub_region_1 = "New York"
    AND sub_region_2 IN ("Bronx County", "Queens County", "Kings County", "New York County", "Richmond County")
    AND date >= '2019-01-01'
    AND date < '2020-01-01'
) AS table_2019
