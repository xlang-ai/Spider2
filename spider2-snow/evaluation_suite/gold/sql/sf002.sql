WITH "FilteredData" AS (
  SELECT
    "ID_RSSD"::NUMBER AS "ID_RSSD_NUM",
    "VARIABLE",
    "VALUE"
  FROM "FINANCE__ECONOMICS"."CYBERSYN"."FINANCIAL_INSTITUTION_TIMESERIES"
  WHERE "DATE" = '2022-12-31'
    AND "VARIABLE" IN ('ASSET', 'ESTINS')
),
"BankFinancials" AS (
  SELECT
    "ID_RSSD_NUM",
    MAX(CASE WHEN "VARIABLE" = 'ASSET' THEN "VALUE" END) AS "TotalAssets",
    MAX(CASE WHEN "VARIABLE" = 'ESTINS' THEN "VALUE" END) AS "InsuredPercentage"
  FROM "FilteredData"
  GROUP BY "ID_RSSD_NUM"
)
SELECT
  "E"."NAME",
  (1 - "BF"."InsuredPercentage") * 100 AS "Uninsured_Assets_Percentage"
FROM "FINANCE__ECONOMICS"."CYBERSYN"."FINANCIAL_INSTITUTION_ENTITIES" AS "E"
JOIN "BankFinancials" AS "BF"
  ON "E"."ID_RSSD" = "BF"."ID_RSSD_NUM"
WHERE
  "E"."IS_ACTIVE" = TRUE
  AND "BF"."TotalAssets" > 10000000000
  AND "BF"."InsuredPercentage" IS NOT NULL
ORDER BY
  "Uninsured_Assets_Percentage" DESC
LIMIT 10;