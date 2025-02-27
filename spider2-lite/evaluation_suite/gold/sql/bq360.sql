WITH specialist_counts AS (
  SELECT
    healthcare_provider_taxonomy_1_specialization,
    COUNT(DISTINCT npi) AS number_specialist
  FROM
    `bigquery-public-data.nppes.npi_optimized`
  WHERE
    provider_business_practice_location_address_city_name = "MOUNTAIN VIEW"
    AND provider_business_practice_location_address_state_name = "CA"
    AND healthcare_provider_taxonomy_1_specialization > ""
  GROUP BY
    healthcare_provider_taxonomy_1_specialization
),
top_10_specialists AS (
  SELECT
    healthcare_provider_taxonomy_1_specialization,
    number_specialist
  FROM
    specialist_counts
  ORDER BY
    number_specialist DESC
  LIMIT 10
),
average_value AS (
  SELECT
    AVG(number_specialist) AS average_specialist
  FROM
    top_10_specialists
),
closest_to_average AS (
  SELECT
    healthcare_provider_taxonomy_1_specialization,
    number_specialist,
    ABS(number_specialist - (SELECT average_specialist FROM average_value)) AS difference
  FROM
    top_10_specialists
)
SELECT
  healthcare_provider_taxonomy_1_specialization
FROM
  closest_to_average
ORDER BY
  difference
LIMIT 1;