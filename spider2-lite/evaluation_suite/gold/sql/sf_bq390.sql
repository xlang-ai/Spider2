WITH
-- Studies that have MR volumes
"mr_studies" AS (
  SELECT
    "dicom_all_mr"."StudyInstanceUID"
  FROM
    "IDC"."IDC_V17"."DICOM_ALL" AS "dicom_all_mr"
  WHERE
    "Modality" = 'MR'
    AND "collection_id" = 'qin_prostate_repeatability'
    AND CONTAINS("SeriesDescription", 'T2 Weighted Axial')
),

"seg_studies" AS (
  SELECT
    "dicom_all_seg"."StudyInstanceUID"
  FROM
    "IDC"."IDC_V17"."DICOM_ALL" AS "dicom_all_seg"
  JOIN
    "IDC"."IDC_V17"."SEGMENTATIONS" AS "segmentations"
  ON
    "dicom_all_seg"."SOPInstanceUID" = "segmentations"."SOPInstanceUID"
  WHERE
    "collection_id" = 'qin_prostate_repeatability'
    AND CONTAINS("segmentations"."SegmentedPropertyType":"CodeMeaning", 'Peripheral zone')
    AND "segmentations"."SegmentedPropertyCategory":"CodeMeaning" = 'Anatomical Structure'
)

SELECT DISTINCT
  "mr_studies"."StudyInstanceUID"
FROM
  "mr_studies"
JOIN
  "seg_studies"
ON
  "mr_studies"."StudyInstanceUID" = "seg_studies"."StudyInstanceUID";
