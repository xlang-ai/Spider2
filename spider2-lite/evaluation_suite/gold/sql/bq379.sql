WITH AvgScore AS (
  SELECT
    AVG(associations.score) AS avg_score
  FROM
    `open-targets-prod.platform.associationByOverallDirect` AS associations
  JOIN
    `open-targets-prod.platform.diseases` AS diseases
  ON
    associations.diseaseId = diseases.id
  WHERE
    diseases.name = 'psoriasis'
)
SELECT
  targets.approvedSymbol AS target_approved_symbol
FROM
  `open-targets-prod.platform.associationByOverallDirect` AS associations
JOIN
  `open-targets-prod.platform.diseases` AS diseases
ON
  associations.diseaseId = diseases.id
JOIN
  `open-targets-prod.platform.targets` AS targets
ON
  associations.targetId = targets.id
CROSS JOIN
  AvgScore
WHERE
  diseases.name = 'psoriasis'
ORDER BY
  ABS(associations.score - AvgScore.avg_score) ASC
LIMIT 1
