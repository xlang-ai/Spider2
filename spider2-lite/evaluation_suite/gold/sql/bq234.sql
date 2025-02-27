SELECT
  A.state,
  drug_name,
  total_claim_count
FROM (
  SELECT
    generic_name AS drug_name,
    nppes_provider_state AS state,
    ROUND(SUM(total_claim_count)) AS total_claim_count,
    ROUND(SUM(total_day_supply)) AS day_supply,
    ROUND(SUM(total_drug_cost)) / 1e6 AS total_cost_millions
  FROM
    `bigquery-public-data.cms_medicare.part_d_prescriber_2014`
  GROUP BY
    state,
    drug_name) A
INNER JOIN (
  SELECT
    state,
    MAX(total_claim_count) AS max_total_claim_count
  FROM (
    SELECT
      nppes_provider_state AS state,
      ROUND(SUM(total_claim_count)) AS total_claim_count
    FROM
      `bigquery-public-data.cms_medicare.part_d_prescriber_2014`
    GROUP BY
      state,
      generic_name)
  GROUP BY
    state) B
ON
  A.state = B.state
  AND A.total_claim_count = B.max_total_claim_count;