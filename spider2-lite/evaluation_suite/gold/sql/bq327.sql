WITH russia_Data AS (
  SELECT DISTINCT 
    id.country_name,
    id.value, -- Format in DataStudio
    id.indicator_name
  FROM (
    SELECT
      country_code,
      region
    FROM
      bigquery-public-data.world_bank_intl_debt.country_summary
    WHERE
      region != "" -- Aggregated countries do not have a region
  ) cs -- Aggregated countries do not have a region
  INNER JOIN (
    SELECT
      country_code,
      country_name,
      value, 
      indicator_name
    FROM
      bigquery-public-data.world_bank_intl_debt.international_debt
    WHERE
      country_code = 'RUS'
  ) id
  ON
    cs.country_code = id.country_code
  WHERE value IS NOT NULL
)
-- Count the number of indicators with a value of 0 for Russia
SELECT 
  COUNT(*) AS number_of_indicators_with_zero
FROM 
  russia_Data
WHERE 
  value = 0;