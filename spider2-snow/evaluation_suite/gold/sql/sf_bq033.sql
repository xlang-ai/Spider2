WITH date_series AS (
  SELECT
    DATE_FROM_PARTS(2008, 1, 1) AS month_start
  UNION ALL
  SELECT
    DATEADD(MONTH, 1, month_start)
  FROM date_series
  WHERE month_start < '2022-12-01'
),
filtered_data AS (
  SELECT
    TO_CHAR(TRY_TO_DATE(TO_VARCHAR("filing_date"), 'YYYYMMDD'), 'YYYYMM') AS year_month,
    "publication_number"
  FROM
    "PATENTS"."PUBLICATIONS",
    LATERAL FLATTEN("abstract_localized") abs
  WHERE
    "country_code" = 'US'
    AND LOWER(abs.value:"text"::STRING) LIKE '%internet of things%'
    AND "filing_date" BETWEEN 20080101 AND 20221231
    AND "filing_date" != 0
  GROUP BY year_month, "publication_number"
),
monthly_counts AS (
  SELECT
    year_month,
    COUNT("publication_number") AS application_count
  FROM filtered_data
  GROUP BY year_month
)
SELECT
  TO_CHAR(ds.month_start, 'YYYYMM') AS "PATENT_DATE_YEARMONTH",
  COALESCE(mc.application_count, 0) AS "NUMBER_OF_PATENT_APPLICATIONS"
FROM date_series ds
LEFT JOIN monthly_counts mc
  ON TO_CHAR(ds.month_start, 'YYYYMM') = mc.year_month
ORDER BY "PATENT_DATE_YEARMONTH"