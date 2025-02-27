WITH ny_top_drug AS (
  SELECT
    drug_name AS drug_name,
    ROUND(SUM(total_claim_count)) AS total_claim_count
  FROM
    `bigquery-public-data.cms_medicare.part_d_prescriber_2014`
  WHERE
    nppes_provider_state = 'NY'
  GROUP BY
    drug_name
  ORDER BY
    total_claim_count DESC
  LIMIT 1
),
top_5_states AS (
  SELECT
    nppes_provider_state AS state,
    SUM(total_claim_count) AS total_claim_count,
    SUM(total_drug_cost) AS total_drug_cost
  FROM
    `bigquery-public-data.cms_medicare.part_d_prescriber_2014`
  WHERE
    drug_name = (SELECT drug_name FROM ny_top_drug)
  GROUP BY
    state
  ORDER BY
    total_claim_count DESC
  LIMIT 5
)
SELECT
  state,
  total_claim_count,
  total_drug_cost
FROM
  top_5_states;