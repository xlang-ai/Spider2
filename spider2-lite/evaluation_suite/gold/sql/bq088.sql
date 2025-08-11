SELECT
  table_2019.avg_symptom_Anxiety_2019,
  table_2020.avg_symptom_Anxiety_2020,
  ((table_2020.avg_symptom_Anxiety_2020 - table_2019.avg_symptom_Anxiety_2019)/table_2019.avg_symptom_Anxiety_2019) * 100 AS percent_increase_anxiety,
  table_2019.avg_symptom_Depression_2019,
  table_2020.avg_symptom_Depression_2020,
  ((table_2020.avg_symptom_Depression_2020 - table_2019.avg_symptom_Depression_2019)/table_2019.avg_symptom_Depression_2019) * 100 AS percent_increase_depression
FROM (
  SELECT
    AVG(CAST(symptom_Anxiety AS FLOAT64)) AS avg_symptom_Anxiety_2020,
    AVG(CAST(symptom_Depression AS FLOAT64)) AS avg_symptom_Depression_2020,
  FROM
    `bigquery-public-data.covid19_symptom_search.symptom_search_country_weekly`
  WHERE
    country_region_code = "US"
    AND date >= '2020-01-01'
    AND date <'2021-01-01') AS table_2020,
  (
  SELECT
    AVG(CAST(symptom_Anxiety AS FLOAT64)) AS avg_symptom_Anxiety_2019,
    AVG(CAST(symptom_Depression AS FLOAT64)) AS avg_symptom_Depression_2019,
  FROM
    `bigquery-public-data.covid19_symptom_search.symptom_search_country_weekly`
  WHERE
    country_region_code = "US"
    AND date >= '2019-01-01'
    AND date <'2020-01-01') AS table_2019