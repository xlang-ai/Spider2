WITH
  # FIRST CAST EACH YEAR, MONTH, DATE TO STRINGS
  T AS (
    SELECT
      *,
      CAST(year AS STRING) AS year_string,
      CAST(mo AS STRING) AS month_string,
      CAST(da AS STRING) AS day_string
    FROM
      `bigquery-public-data.noaa_gsod.gsod2009`
    WHERE
      stn = "723758"
  ),

  # SECOND, CONCAT ALL THE STRINGS TOGETHER INTO ONE COLUMN
  TT AS (
    SELECT
      *,
      CONCAT(year_string, "-", month_string, "-", day_string) AS date_string
    FROM
      T
  ),

  # THIRD, CAST THE DATE STRING INTO A DATE FORMAT
  TTT AS (
    SELECT
      *,
      CAST(date_string AS DATE) AS date_date
    FROM
      TT
  ),

  # FOURTH, CALCULATE THE MEAN TEMPERATURE FOR EACH DATE
  Temp_Avg AS (
    SELECT
      date_date,
      AVG(temp) AS avg_temp
    FROM
      TTT
    WHERE
      date_date BETWEEN '2009-10-01' AND '2009-10-31'
    GROUP BY
      date_date
  )

# FINAL SELECTION OF TOP 3 DATES WITH HIGHEST MEAN TEMPERATURE
SELECT
  date_date AS dates
FROM
  Temp_Avg
ORDER BY
  avg_temp DESC
LIMIT 3;