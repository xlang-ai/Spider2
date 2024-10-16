WITH
  SpecimenPreparationSequence_unnested AS (
  SELECT
    SOPInstanceUID,
    concept_name_code_sequence.CodeMeaning AS cnc_cm,
    concept_name_code_sequence.CodingSchemeDesignator AS cnc_csd,
    concept_name_code_sequence.CodeValue AS cnc_val,
    concept_code_sequence.CodeMeaning AS ccs_cm,
    concept_code_sequence.CodingSchemeDesignator AS ccs_csd,
    concept_code_sequence.CodeValue AS ccs_val
  FROM
    `spider2-public-data.idc_v17.dicom_all`,
    UNNEST(SpecimenDescriptionSequence[SAFE_OFFSET(0)].SpecimenPreparationSequence) AS preparation_unnest_step1,
    UNNEST(preparation_unnest_step1.SpecimenPreparationStepContentItemSequence) AS preparation_unnest_step2,
    UNNEST(preparation_unnest_step2.ConceptNameCodeSequence) AS concept_name_code_sequence,
    UNNEST(preparation_unnest_step2.ConceptCodeSequence) AS concept_code_sequence ),
  
  slide_embedding AS (
  SELECT
    SOPInstanceUID,
    ARRAY_AGG(DISTINCT(CONCAT(ccs_cm, ":", ccs_csd, ":", ccs_val))) AS embeddingMedium_code_str
  FROM
    SpecimenPreparationSequence_unnested
  WHERE
    (cnc_csd = 'SCT' AND cnc_val = '430863003') -- CodeMeaning is 'Embedding medium'
  GROUP BY
    SOPInstanceUID ),
    
  slide_staining AS (
  SELECT
    SOPInstanceUID,
    ARRAY_AGG(DISTINCT(CONCAT(ccs_cm, ":", ccs_csd, ":", ccs_val))) AS staining_usingSubstance_code_str
  FROM
    SpecimenPreparationSequence_unnested
  WHERE
    (cnc_csd = 'SCT' AND cnc_val = '424361007') -- CodeMeaning is 'Using substance'
  GROUP BY
    SOPInstanceUID )
  
-- Step 1: Find the most frequent embedding medium
SELECT
  embeddingMedium_CodeMeaning,
  staining_usingSubstance_CodeMeaning
FROM (
  SELECT
    d.SOPInstanceUID,
    d.instance_size,
    -- Get embedding medium code meaning
    ARRAY(
      SELECT IF (code IS NULL, NULL, SPLIT(code, ':')[SAFE_OFFSET(0)])
      FROM UNNEST(e.embeddingMedium_code_str) AS code
    ) AS embeddingMedium_CodeMeaning,
    -- Get staining substance code meaning
    ARRAY(
      SELECT IF (code IS NULL, NULL, SPLIT(code, ':')[SAFE_OFFSET(0)])
      FROM UNNEST(s.staining_usingSubstance_code_str) AS code
    ) AS staining_usingSubstance_CodeMeaning
  FROM
    `spider2-public-data.idc_v17.dicom_all` AS d
  LEFT JOIN
    slide_embedding AS e ON d.SOPInstanceUID = e.SOPInstanceUID
  LEFT JOIN
    slide_staining AS s ON d.SOPInstanceUID = s.SOPInstanceUID
  WHERE
    d.Modality = "SM"
) AS embedding_data
-- Flatten both arrays for embedding medium and staining substance
CROSS JOIN
  UNNEST(embeddingMedium_CodeMeaning) AS embeddingMedium_CodeMeaning
CROSS JOIN
  UNNEST(staining_usingSubstance_CodeMeaning) AS staining_usingSubstance_CodeMeaning
GROUP BY
  embeddingMedium_CodeMeaning, staining_usingSubstance_CodeMeaning
-- Step 2: Get the most frequent staining substance for the most frequent embedding medium
ORDER BY
  COUNT(*) OVER (PARTITION BY embeddingMedium_CodeMeaning) DESC, 
  COUNT(*) DESC
LIMIT 1;