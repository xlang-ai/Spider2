WITH
-- Studies that have MR volumes
mr_studies AS (
  SELECT
    dicom_all_mr.StudyInstanceUID
  FROM
    bigquery-public-data.idc_v17.dicom_all AS dicom_all_mr
  WHERE
    Modality = 'MR'
    AND collection_id = 'qin_prostate_repeatability'
    AND REGEXP_CONTAINS(SeriesDescription, r"T2 Weighted Axial")
),

-- Studies that have segmentations for the peripheral zone
seg_studies AS (
  SELECT
    dicom_all_seg.StudyInstanceUID
  FROM
    bigquery-public-data.idc_v17.dicom_all AS dicom_all_seg
  JOIN
    bigquery-public-data.idc_v17.segmentations AS segmentations
  ON
    dicom_all_seg.SOPInstanceUID = segmentations.SOPInstanceUID
  WHERE
    collection_id = 'qin_prostate_repeatability'
    AND REGEXP_CONTAINS(segmentations.SegmentedPropertyType.CodeMeaning, r"Peripheral zone")
    AND segmentations.SegmentedPropertyCategory.CodeMeaning = 'Anatomical Structure'
)

SELECT DISTINCT
  mr_studies.StudyInstanceUID
FROM
  mr_studies
JOIN
  seg_studies
ON
  mr_studies.StudyInstanceUID = seg_studies.StudyInstanceUID
