DECLARE
  my_drug_list ARRAY<STRING>;
SET
  my_drug_list = [
  'Keytruda',
  'Vioxx',
  'Humira',
  'Premarin' ];

SELECT
  id AS drug_id,
  tradeNameList.element AS drug_trade_name,
  drugType AS drug_type,
  hasBeenWithdrawn AS drug_withdrawn
FROM
  `open-targets-prod.platform.molecule`,
  UNNEST (tradeNames.list) AS tradeNameList
WHERE
  tradeNameList.element IN UNNEST(my_drug_list)
  AND isApproved = TRUE
  AND blackBoxWarning = TRUE
  AND drugType != 'Unknown';
