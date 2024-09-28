SELECT
  targets.approvedSymbol AS target_symbol,
  drugs.name AS drug_name,
  source_urls.element.url AS clinical_trial_reference_url,
FROM
  `open-targets-prod.platform.evidence` AS evidence,
  UNNEST(evidence.urls.list) AS source_urls
JOIN
  `open-targets-prod.platform.targets` AS targets
ON
  evidence.targetId=targets.id
JOIN
  `open-targets-prod.platform.molecule` AS drugs
ON
  evidence.drugId=drugs.id
WHERE
  datasourceId="chembl"
  AND diseaseId="EFO_0007416"
  AND evidence.clinicalStatus = "Completed"