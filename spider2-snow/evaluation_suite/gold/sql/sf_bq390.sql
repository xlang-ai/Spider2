SELECT DISTINCT
  T1."StudyInstanceUID"
FROM "IDC"."IDC_V17"."DICOM_ALL" AS T1
INNER JOIN "IDC"."IDC_V17"."SEGMENTATIONS" AS T2
  ON T1."StudyInstanceUID" = T2."StudyInstanceUID"
WHERE
  T1."collection_id" = 'qin_prostate_repeatability'
  AND T1."SeriesDescription" = 'T2 Weighted Axial'
  AND T2."SegmentedPropertyType":CodeMeaning::STRING = 'Peripheral zone of the prostate'