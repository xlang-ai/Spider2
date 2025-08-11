SELECT
  Provider_Name
FROM
(
SELECT
  OP.provider_state AS State,
  OP.provider_city AS City,
  OP.provider_id AS Provider_ID,
  OP.provider_name AS Provider_Name,
  ROUND(OP.average_OP_cost) AS Average_OP_Cost,
  ROUND(IP.average_IP_cost) AS Average_IP_Cost,
  ROUND(OP.average_OP_cost + IP.average_IP_cost) AS Combined_Average_Cost
FROM (
  SELECT
    provider_state,
    provider_city,
    provider_id,
    provider_name,
    SUM(average_total_payments*outpatient_services)/SUM(outpatient_services) AS average_OP_cost
  FROM
    `bigquery-public-data.cms_medicare.outpatient_charges_2014`
  GROUP BY
    provider_state,
    provider_city,
    provider_id,
    provider_name ) AS OP
INNER JOIN (
  SELECT
    provider_state,
    provider_city,
    provider_id,
    provider_name,
    SUM(average_medicare_payments*total_discharges)/SUM(total_discharges) AS average_IP_cost
  FROM
    `bigquery-public-data.cms_medicare.inpatient_charges_2014`
  GROUP BY
    provider_state,
    provider_city,
    provider_id,
    provider_name ) AS IP
ON
  OP.provider_id = IP.provider_id
  AND OP.provider_state = IP.provider_state
  AND OP.provider_city = IP.provider_city
  AND OP.provider_name = IP.provider_name
ORDER BY
  combined_average_cost DESC
LIMIT
  1
);