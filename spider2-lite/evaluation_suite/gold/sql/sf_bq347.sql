WITH union_mr_seg AS (
  SELECT
    "dicom_all_mr"."SOPInstanceUID",
    '' AS "segPropertyTypeCodeMeaning", 
    '' AS "segPropertyCategoryCodeMeaning"
  FROM
    "IDC"."IDC_V17"."DICOM_ALL" AS "dicom_all_mr"
  WHERE
    "dicom_all_mr"."SeriesInstanceUID" IN ('1.3.6.1.4.1.14519.5.2.1.3671.4754.105976129314091491952445656147')
    
  UNION ALL

  SELECT
    "dicom_all_seg"."SOPInstanceUID",
    "segmentations"."SegmentedPropertyType":"CodeMeaning" AS "segPropertyTypeCodeMeaning",
    "segmentations"."SegmentedPropertyCategory":"CodeMeaning" AS "segPropertyCategoryCodeMeaning"
  FROM
    "IDC"."IDC_V17"."DICOM_ALL" AS "dicom_all_seg"
  JOIN
    "IDC"."IDC_V17"."SEGMENTATIONS" AS "segmentations"
  ON
    "dicom_all_seg"."SOPInstanceUID" = "segmentations"."SOPInstanceUID"
)

SELECT
  "dc_all"."Modality",
  COUNT(*) AS "count_"
FROM 
  "IDC"."IDC_V17"."DICOM_ALL" AS "dc_all"
INNER JOIN
  union_mr_seg
ON 
  "dc_all"."SOPInstanceUID" = union_mr_seg."SOPInstanceUID"
GROUP BY
  "dc_all"."Modality"
ORDER BY
  "count_" DESC
LIMIT 1;
