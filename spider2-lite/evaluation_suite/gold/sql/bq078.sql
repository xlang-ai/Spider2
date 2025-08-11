SELECT
  T1.targetId AS target_id,
  T1.datasourceId,
  targets.approvedSymbol AS approved_symbol,
  overall_associations.score AS overall_score
FROM
  `bigquery-public-data.open_targets_platform.associationByDatasourceDirect` as T1
JOIN
  `bigquery-public-data.open_targets_platform.targets` AS targets
ON
  targetId = targets.id
JOIN
  `bigquery-public-data.open_targets_platform.associationByOverallDirect` AS overall_associations
ON
  T1.targetId = overall_associations.targetId
WHERE
  overall_associations.diseaseId = 'EFO_0000676' AND datasourceId = 'impc'
ORDER BY
  overall_associations.score DESC
LIMIT
  1;
