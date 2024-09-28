SELECT DISTINCT
  id.country_name,
  --cs.region,
  id.value AS debt,
  --id.indicator_code
FROM (
  SELECT
    country_code,
    region
  FROM
    `bigquery-public-data.world_bank_intl_debt.country_summary`
  WHERE
    region != "" ) cs
INNER JOIN (
  SELECT
    country_code,
    country_name,
    value,
    indicator_code
  FROM
    `bigquery-public-data.world_bank_intl_debt.international_debt`
  WHERE
    indicator_code = "DT.AMT.DLXF.CD") id

ON
  cs.country_code = id.country_code
ORDER BY
  id.value DESC
  LIMIT 10