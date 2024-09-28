WITH specimen_preparation_sequence_items AS (
  SELECT DISTINCT
    SeriesInstanceUID AS digital_slide_id,
    steps_unnested2.ConceptNameCodeSequence[SAFE_OFFSET(0)].CodeMeaning AS item_name,
    steps_unnested2.ConceptCodeSequence[SAFE_OFFSET(0)].CodeMeaning AS item_value
  FROM
    `bigquery-public-data.idc_v11.dicom_all`
  CROSS JOIN
    UNNEST(SpecimenDescriptionSequence[SAFE_OFFSET(0)].SpecimenPreparationSequence) AS steps_unnested1
  CROSS JOIN
    UNNEST(steps_unnested1.SpecimenPreparationStepContentItemSequence) AS steps_unnested2
),

grouped_by_study AS (
  SELECT
    dicom.StudyInstanceUID AS case_id,
    ANY_VALUE(dicom.ContainerIdentifier) AS physical_slide_id
  FROM
    `bigquery-public-data.idc_v18.dicom_all` AS dicom
  WHERE
    dicom.Modality = 'SM' AND
    EXISTS (
      SELECT 1
      FROM specimen_preparation_sequence_items AS specimen
      WHERE dicom.SeriesInstanceUID = specimen.digital_slide_id
        AND specimen.item_value LIKE '%eosin%'
    )
  GROUP BY
    dicom.StudyInstanceUID
)

SELECT
  SUM(CAST(dicom.NumberOfFrames AS INT64)) AS total_frames
FROM
  grouped_by_study AS study
JOIN
  `bigquery-public-data.idc_v18.dicom_all` AS dicom
ON
  dicom.StudyInstanceUID = study.case_id
  AND dicom.ContainerIdentifier = study.physical_slide_id
LEFT JOIN
  specimen_preparation_sequence_items AS specimen
ON
  dicom.SeriesInstanceUID = specimen.digital_slide_id
WHERE
  dicom.Modality = 'SM' AND
  dicom.collection_name = 'TCGA-BRCA';