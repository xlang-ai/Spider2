WITH country_data AS (
  -- CTE for country descriptive data
  SELECT 
    country_code, 
    short_name AS country,
    region, 
    income_group 
  FROM 
    `bigquery-public-data.world_bank_wdi.country_summary`
),

gdp_data AS (
  -- Filter data to only include GDP values
  SELECT 
    data.country_code, 
    country,
    region,
    value AS gdp_value
  FROM 
    `bigquery-public-data.world_bank_wdi.indicators_data` data
  LEFT JOIN country_data
    ON data.country_code = country_data.country_code
  WHERE indicator_code = "NY.GDP.MKTP.KD" -- GDP Indicator
    AND country_data.region IS NOT NULL
    AND country_data.income_group IS NOT NULL
),

cal_median_gdp AS (
  -- Calculate the median GDP value for each region
  SELECT 
    region,
    APPROX_QUANTILES(gdp_value, 2)[OFFSET(1)] AS median_gdp
  FROM gdp_data
  GROUP BY region
)
-- Select the regions with their median GDP values
SELECT 
  region
FROM 
  cal_median_gdp
ORDER BY median_gdp DESC
LIMIT 1;