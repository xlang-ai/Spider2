SELECT
  "collection_id",
  "StudyInstanceUID" AS "study_id",
  "SeriesInstanceUID" AS "series_id",
  'https://viewer.imaging.datacommons.cancer.gov/viewer/' || "StudyInstanceUID" AS "viewer_url",
  ROUND(SUM("instance_size") / 1024) AS "size_kb"
FROM "IDC"."IDC_V17"."DICOM_ALL"
WHERE
  "Modality" IN ('SEG','RTSTRUCT')
  AND "SOPClassUID" = '1.2.840.10008.5.1.4.1.1.66.4'
  AND COALESCE(ARRAY_SIZE("ReferencedSeriesSequence"), 0) = 0
  AND COALESCE(ARRAY_SIZE("ReferencedImageSequence"), 0) = 0
  AND COALESCE(ARRAY_SIZE("SourceImageSequence"), 0) = 0
GROUP BY
  "collection_id",
  "StudyInstanceUID",
  "SeriesInstanceUID",
  'https://viewer.imaging.datacommons.cancer.gov/viewer/' || "StudyInstanceUID"
ORDER BY
  "size_kb" DESC;