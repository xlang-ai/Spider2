WITH Patent_Matches AS (
    SELECT
      TO_DATE(CAST(ANY_VALUE(patentsdb."filing_date") AS STRING), 'YYYYMMDD') AS Patent_Filing_Date,
      patentsdb."application_number" AS Patent_Application_Number,
      MAX(abstract_info.value:"text") AS Patent_Title,
      MAX(abstract_info.value:"language") AS Patent_Title_Language
    FROM
      PATENTS.PATENTS.PUBLICATIONS AS patentsdb,
      LATERAL FLATTEN(input => patentsdb."abstract_localized") AS abstract_info
    WHERE
      LOWER(abstract_info.value:"text") LIKE '%internet of things%'
      AND patentsdb."country_code" = 'US'
    GROUP BY
      Patent_Application_Number
),

Date_Series_Table AS (
    SELECT
        DATEADD(day, seq4(), DATE '2008-01-01') AS day,
        0 AS Number_of_Patents
    FROM
        TABLE(
            GENERATOR(
                ROWCOUNT => 5479
            )
        )
    ORDER BY
        day
)

SELECT
  TO_CHAR(Date_Series_Table.day, 'YYYY-MM') AS Patent_Date_YearMonth,
  COUNT(Patent_Matches.Patent_Application_Number) AS Number_of_Patent_Applications
FROM
  Date_Series_Table
  LEFT JOIN Patent_Matches
    ON Date_Series_Table.day = Patent_Matches.Patent_Filing_Date
WHERE
    Date_Series_Table.day < DATE '2023-01-01'
GROUP BY
  TO_CHAR(Date_Series_Table.day, 'YYYY-MM')
ORDER BY
  Patent_Date_YearMonth;
