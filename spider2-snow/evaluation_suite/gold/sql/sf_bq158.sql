WITH clinical_brca AS (
  SELECT DISTINCT
    c."bcr_patient_barcode" AS "ParticipantBarcode",
    c."histological_type"
  FROM "PANCANCER_ATLAS_1"."PANCANCER_ATLAS_FILTERED"."CLINICAL_PANCAN_PATIENT_WITH_FOLLOWUP_FILTERED" c
  WHERE c."acronym" = 'BRCA'
    AND c."histological_type" IS NOT NULL
),
brca_patients AS (
  SELECT DISTINCT
    m."ParticipantBarcode"
  FROM "PANCANCER_ATLAS_1"."PANCANCER_ATLAS_FILTERED"."MC3_MAF_V5_ONE_PER_TUMOR_SAMPLE" m
  WHERE m."Study" = 'BRCA'
),
denom_hist AS (
  SELECT
    p."ParticipantBarcode",
    cb."histological_type"
  FROM brca_patients p
  JOIN clinical_brca cb
    ON p."ParticipantBarcode" = cb."ParticipantBarcode"
),
cdh1_mutants AS (
  SELECT DISTINCT
    m."ParticipantBarcode"
  FROM "PANCANCER_ATLAS_1"."PANCANCER_ATLAS_FILTERED"."MC3_MAF_V5_ONE_PER_TUMOR_SAMPLE" m
  WHERE m."Study" = 'BRCA'
    AND m."Hugo_Symbol" = 'CDH1'
)
SELECT
  dh."histological_type" AS "histological_type",
  COUNT(DISTINCT CASE WHEN cm."ParticipantBarcode" IS NOT NULL THEN dh."ParticipantBarcode" END) AS "mutated_cases",
  COUNT(DISTINCT dh."ParticipantBarcode") AS "total_cases",
  100.0 * COUNT(DISTINCT CASE WHEN cm."ParticipantBarcode" IS NOT NULL THEN dh."ParticipantBarcode" END)
    / NULLIF(COUNT(DISTINCT dh."ParticipantBarcode"), 0) AS "cdh1_mutation_percentage"
FROM denom_hist dh
LEFT JOIN cdh1_mutants cm
  ON dh."ParticipantBarcode" = cm."ParticipantBarcode"
GROUP BY dh."histological_type"
ORDER BY "cdh1_mutation_percentage" DESC
LIMIT 5;