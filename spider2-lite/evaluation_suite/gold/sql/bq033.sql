WITH
  Patent_Matches AS (
    SELECT
      PARSE_DATE('%Y%m%d', SAFE_CAST(ANY_VALUE(patentsdb.filing_date) AS STRING)) AS Patent_Filing_Date,
      patentsdb.application_number AS Patent_Application_Number,
      ANY_VALUE(abstract_info.text) AS Patent_Title,
      ANY_VALUE(abstract_info.language) AS Patent_Title_Language
    FROM
      `spider2-public-data.patents.publications` AS patentsdb,
      UNNEST(abstract_localized) AS abstract_info
    WHERE
      LOWER(abstract_info.text) LIKE '%internet of things%'
      AND patentsdb.country_code = 'US'
    GROUP BY
      Patent_Application_Number
  ),

  Date_Series_Table AS (
    SELECT
      day,
      0 AS Number_of_Patents
    FROM
      UNNEST(GENERATE_DATE_ARRAY(
        DATE '2008-01-01', 
        DATE '2022-12-31'
      )) AS day
  )

SELECT
  SAFE_CAST(FORMAT_DATE('%Y-%m', Date_Series_Table.day) AS STRING) AS Patent_Date_YearMonth,
  COUNT(Patent_Matches.Patent_Application_Number) AS Number_of_Patent_Applications
FROM
  Date_Series_Table
  LEFT JOIN Patent_Matches
    ON Date_Series_Table.day = Patent_Matches.Patent_Filing_Date
GROUP BY
  Patent_Date_YearMonth
ORDER BY
  Patent_Date_YearMonth;