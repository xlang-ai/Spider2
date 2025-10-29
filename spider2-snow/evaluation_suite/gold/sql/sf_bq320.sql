SELECT COUNT(DISTINCT "StudyInstanceUID") AS "unique_study_count"
FROM "IDC"."IDC_V17"."DICOM_PIVOT"
WHERE "SegmentedPropertyTypeCodeSequence" IS NOT NULL
  AND LOWER(TRIM("SegmentedPropertyTypeCodeSequence")) = '15825003'
  AND LOWER(TRIM("collection_id")) IN ('community', 'nsclc_radiomics');