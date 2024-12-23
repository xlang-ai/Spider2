WITH
  SpecimenPreparationSequence_unnested AS (
    SELECT
      d."SOPInstanceUID",
      concept_name_code_sequence.value:"CodeMeaning"::STRING AS "cnc_cm",
      concept_name_code_sequence.value:"CodingSchemeDesignator"::STRING AS "cnc_csd",
      concept_name_code_sequence.value:"CodeValue"::STRING AS "cnc_val",
      concept_code_sequence.value:"CodeMeaning"::STRING AS "ccs_cm",
      concept_code_sequence.value:"CodingSchemeDesignator"::STRING AS "ccs_csd",
      concept_code_sequence.value:"CodeValue"::STRING AS "ccs_val"
    FROM
      "IDC"."IDC_V17"."DICOM_ALL" AS d,
      LATERAL FLATTEN(input => d."SpecimenDescriptionSequence") AS spec_desc,
      LATERAL FLATTEN(input => spec_desc.value:"SpecimenPreparationSequence") AS prep_seq,
      LATERAL FLATTEN(input => prep_seq.value:"SpecimenPreparationStepContentItemSequence") AS prep_step,
      LATERAL FLATTEN(input => prep_step.value:"ConceptNameCodeSequence") AS concept_name_code_sequence,
      LATERAL FLATTEN(input => prep_step.value:"ConceptCodeSequence") AS concept_code_sequence
  ),
  slide_embedding AS (
    SELECT
      "SOPInstanceUID",
      ARRAY_AGG(DISTINCT(CONCAT("ccs_cm", ':', "ccs_csd", ':', "ccs_val"))) AS "embeddingMedium_code_str"
    FROM
      SpecimenPreparationSequence_unnested
    WHERE
      "cnc_csd" = 'SCT' AND "cnc_val" = '430863003' -- CodeMeaning is 'Embedding medium'
    GROUP BY
      "SOPInstanceUID"
  ),
  slide_staining AS (
    SELECT
      "SOPInstanceUID",
      ARRAY_AGG(DISTINCT(CONCAT("ccs_cm", ':', "ccs_csd", ':', "ccs_val"))) AS "staining_usingSubstance_code_str"
    FROM
      SpecimenPreparationSequence_unnested
    WHERE
      "cnc_csd" = 'SCT' AND "cnc_val" = '424361007' -- CodeMeaning is 'Using substance'
    GROUP BY
      "SOPInstanceUID"
  ),
  embedding_data AS (
    SELECT
      d."SOPInstanceUID",
      d."instance_size",
      e."embeddingMedium_code_str",
      s."staining_usingSubstance_code_str"
    FROM
      "IDC"."IDC_V17"."DICOM_ALL" AS d
    LEFT JOIN
      slide_embedding AS e ON d."SOPInstanceUID" = e."SOPInstanceUID"
    LEFT JOIN
      slide_staining AS s ON d."SOPInstanceUID" = s."SOPInstanceUID"
    WHERE
      d."Modality" = 'SM'
  )
SELECT
  SPLIT_PART(embeddingMedium_CodeMeaning_flat.VALUE::STRING, ':', 1) AS "embeddingMedium_CodeMeaning",
  SPLIT_PART(staining_usingSubstance_CodeMeaning_flat.VALUE::STRING, ':', 1) AS "staining_usingSubstance_CodeMeaning",
  COUNT(*) AS "count_"
FROM
  embedding_data
  , LATERAL FLATTEN(input => embedding_data."embeddingMedium_code_str") AS embeddingMedium_CodeMeaning_flat
  , LATERAL FLATTEN(input => embedding_data."staining_usingSubstance_code_str") AS staining_usingSubstance_CodeMeaning_flat
GROUP BY
  SPLIT_PART(embeddingMedium_CodeMeaning_flat.VALUE::STRING, ':', 1),
  SPLIT_PART(staining_usingSubstance_CodeMeaning_flat.VALUE::STRING, ':', 1);
