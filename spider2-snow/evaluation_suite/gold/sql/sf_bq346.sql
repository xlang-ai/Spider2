WITH segs AS (
  SELECT d."SOPInstanceUID"
  FROM "IDC"."IDC_V17"."DICOM_ALL" d
  WHERE d."access" = 'Public'
    AND d."Modality" = 'SEG'
    AND d."SOPClassUID" = '1.2.840.10008.5.1.4.1.1.66.4'
),
refs AS (
  SELECT s."SOPInstanceUID" AS "seg_sop", d."ReferencedSOPInstanceUID"::string AS "ref_sop"
  FROM segs s
  JOIN "IDC"."IDC_V17"."DICOM_ALL" d ON d."SOPInstanceUID" = s."SOPInstanceUID"
  WHERE d."ReferencedSOPInstanceUID" IS NOT NULL
  UNION ALL
  SELECT s."SOPInstanceUID", f.value:"ReferencedSOPInstanceUID"::string
  FROM segs s
  JOIN "IDC"."IDC_V17"."DICOM_ALL" d ON d."SOPInstanceUID" = s."SOPInstanceUID",
       LATERAL FLATTEN(INPUT => d."SourceImageSequence") f
  WHERE f.value:"ReferencedSOPInstanceUID" IS NOT NULL
  UNION ALL
  SELECT s."SOPInstanceUID", f.value:"ReferencedSOPInstanceUID"::string
  FROM segs s
  JOIN "IDC"."IDC_V17"."DICOM_ALL" d ON d."SOPInstanceUID" = s."SOPInstanceUID",
       LATERAL FLATTEN(INPUT => d."ReferencedImageSequence") f
  WHERE f.value:"ReferencedSOPInstanceUID" IS NOT NULL
  UNION ALL
  SELECT s."SOPInstanceUID", f2.value:"ReferencedSOPInstanceUID"::string
  FROM segs s
  JOIN "IDC"."IDC_V17"."DICOM_ALL" d ON d."SOPInstanceUID" = s."SOPInstanceUID",
       LATERAL FLATTEN(INPUT => d."DerivationImageSequence") f1,
       LATERAL FLATTEN(INPUT => f1.value:"SourceImageSequence") f2
  WHERE f2.value:"ReferencedSOPInstanceUID" IS NOT NULL
  UNION ALL
  SELECT s."SOPInstanceUID", ri.value:"ReferencedSOPInstanceUID"::string
  FROM segs s
  JOIN "IDC"."IDC_V17"."DICOM_ALL" d ON d."SOPInstanceUID" = s."SOPInstanceUID",
       LATERAL FLATTEN(INPUT => d."ReferencedSeriesSequence") rs,
       LATERAL FLATTEN(INPUT => rs.value:"ReferencedInstanceSequence") ri
  WHERE ri.value:"ReferencedSOPInstanceUID" IS NOT NULL
  UNION ALL
  SELECT s."SOPInstanceUID", ri.value:"ReferencedSOPInstanceUID"::string
  FROM segs s
  JOIN "IDC"."IDC_V17"."DICOM_ALL" d ON d."SOPInstanceUID" = s."SOPInstanceUID",
       LATERAL FLATTEN(INPUT => d."ReferencedImageEvidenceSequence") rie,
       LATERAL FLATTEN(INPUT => rie.value:"ReferencedSeriesSequence") rs,
       LATERAL FLATTEN(INPUT => rs.value:"ReferencedInstanceSequence") ri
  WHERE ri.value:"ReferencedSOPInstanceUID" IS NOT NULL
),
seg_with_ref AS (
  SELECT DISTINCT "seg_sop"
  FROM refs
)
SELECT
  seg."SegmentedPropertyCategory":"CodeMeaning"::string AS "SegmentedPropertyCategory_CodeMeaning",
  COUNT(*) AS "count"
FROM "IDC"."IDC_V17"."SEGMENTATIONS" AS seg
JOIN seg_with_ref r
  ON seg."SOPInstanceUID" = r."seg_sop"
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5