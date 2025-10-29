WITH base AS (
  SELECT
    t."SOPInstanceUID",
    t."SeriesInstanceUID",
    t."StudyInstanceUID",
    t."PatientID",
    t."collection_id",
    t."collection_name",
    t."Rows",
    t."Columns",
    t."PixelSpacing",
    t."LossyImageCompressionMethod",
    t."VolumetricProperties",
    t."Modality",
    t."gcs_url",
    sd.value:"SpecimenIdentifier"::STRING AS SPECIMEN_IDENTIFIER,
    pams.value:"CodeValue"::STRING AS TISSUE_CODE,
    pams.value:"CodeMeaning"::STRING AS TISSUE_MEANING
  FROM "IDC"."IDC_V17"."DICOM_ALL" t
  JOIN LATERAL FLATTEN(INPUT => t."SpecimenDescriptionSequence") sd
  JOIN LATERAL FLATTEN(INPUT => sd.value:"PrimaryAnatomicStructureSequence") pas
  JOIN LATERAL FLATTEN(INPUT => pas.value:"PrimaryAnatomicStructureModifierSequence") pams
  JOIN LATERAL FLATTEN(INPUT => sd.value:"SpecimenPreparationSequence") sps
  JOIN LATERAL FLATTEN(INPUT => sps.value:"SpecimenPreparationStepContentItemSequence") sp
  JOIN LATERAL FLATTEN(INPUT => sp.value:"ConceptNameCodeSequence") cn
  LEFT JOIN LATERAL FLATTEN(INPUT => sp.value:"ConceptCodeSequence", OUTER => TRUE) cc
  WHERE t."Modality" = 'SM'
    AND t."VolumetricProperties" = 'VOLUME'
    AND (
      t."collection_name" IN ('TCGA-LUAD', 'TCGA-LUSC') OR
      t."collection_id" IN ('tcga_luad', 'tcga_lusc') OR
      t."tcia_api_collection_id" IN ('TCGA-LUAD', 'TCGA-LUSC') OR
      t."idc_webapp_collection_id" IN ('TCGA-LUAD', 'TCGA-LUSC')
    )
    AND cn.value:"CodeMeaning"::STRING = 'Embedding medium'
    AND (
      UPPER(COALESCE(sp.value:"TextValue"::STRING, '')) = 'TISSUE FREEZING MEDIUM'
      OR UPPER(COALESCE(cc.value:"CodeMeaning"::STRING, '')) = 'TISSUE FREEZING MEDIUM'
    )
    AND (
      pams.value:"CodeValue"::STRING IN ('17621005', '86049000')
      OR UPPER(COALESCE(pams.value:"CodeMeaning"::STRING, '')) IN ('NORMAL', 'NEOPLASM', 'TUMOR')
    )
),
labeled AS (
  SELECT DISTINCT
    b."SOPInstanceUID",
    b."SeriesInstanceUID",
    b."StudyInstanceUID",
    b."PatientID",
    b."collection_id",
    b."collection_name",
    b."Rows",
    b."Columns",
    b."PixelSpacing",
    b."LossyImageCompressionMethod",
    b."gcs_url",
    b.SPECIMEN_IDENTIFIER,
    CASE
      WHEN UPPER(COALESCE(b.TISSUE_MEANING, '')) LIKE 'NORMAL%' THEN 'normal'
      WHEN UPPER(COALESCE(b.TISSUE_MEANING, '')) LIKE '%NEOPLASM%' OR UPPER(COALESCE(b.TISSUE_MEANING, '')) LIKE '%TUMOR%' THEN 'tumor'
      WHEN b.TISSUE_CODE = '17621005' THEN 'normal'
      WHEN b.TISSUE_CODE = '86049000' THEN 'tumor'
      ELSE NULL
    END AS TISSUE_TYPE,
    CASE
      WHEN ARRAY_CONTAINS(TO_VARIANT('ISO_10918_1'), b."LossyImageCompressionMethod") THEN 'jpeg'
      WHEN ARRAY_CONTAINS(TO_VARIANT('ISO_15444_1'), b."LossyImageCompressionMethod") THEN 'jpeg2000'
      ELSE 'other'
    END AS COMPRESSION_TYPE,
    CASE
      WHEN b."collection_name" = 'TCGA-LUAD' OR b."collection_id" = 'tcga_luad' THEN 'luad'
      WHEN b."collection_name" = 'TCGA-LUSC' OR b."collection_id" = 'tcga_lusc' THEN 'lscc'
      ELSE NULL
    END AS CANCER_SUBTYPE
  FROM base b
)
SELECT
  l."SeriesInstanceUID" AS "DIGITAL_SLIDE_ID",
  l."StudyInstanceUID" AS "CASE_ID",
  l.SPECIMEN_IDENTIFIER AS "PHYSICAL_SLIDE_ID",
  l."PatientID" AS "PATIENT_ID",
  l."collection_id" AS "COLLECTION_ID",
  l."SOPInstanceUID" AS "INSTANCE_ID",
  l."gcs_url" AS "GCS_URL",
  l."Columns" AS "WIDTH",
  l."Rows" AS "HEIGHT",
  ROUND(TRY_TO_DOUBLE((l."PixelSpacing"[0])::STRING), 4) AS "PIXEL_SPACING",
  l.COMPRESSION_TYPE AS "COMPRESSION_TYPE",
  l.TISSUE_TYPE AS "TISSUE_TYPE",
  l.CANCER_SUBTYPE AS "CANCER_SUBTYPE"
FROM labeled l
WHERE l.COMPRESSION_TYPE IN ('jpeg', 'jpeg2000')
  AND l.TISSUE_TYPE IN ('normal', 'tumor')
ORDER BY l."SOPInstanceUID" ASC;