SELECT
  ANY_VALUE(PatientID) AS PatientID,
  SeriesInstanceUID,
  ANY_VALUE(StudyInstanceUID) AS StudyInstanceUID,
  ANY_VALUE(StudyDescription) AS StudyDescription,
  ANY_VALUE(Modality) AS Modality,
  COUNT(dicom_all.SOPInstanceUID) AS instanceCount,
  ANY_VALUE(CONCAT("s3://", SPLIT(aws_url, "/")[SAFE_OFFSET(2)], "/", crdc_series_uuid, "/*")) AS series_aws_url,
  ROUND(SUM(SAFE_CAST(instance_size AS float64))/1000000, 2) AS series_size_MB
FROM
  spider2-public-data.idc_v17.dicom_all AS dicom_all
JOIN
  spider2-public-data.idc_v17.dicom_metadata_curated AS dicom_curated
ON
  dicom_all.SOPInstanceUID = dicom_curated.SOPInstanceUID
WHERE
  CAST(REGEXP_EXTRACT(PatientAge, r'\d+') AS INT64) = 18
  AND PatientSex = 'M'
  AND SAFE_CAST(StudyDate AS DATE) > DATE('2014-09-01')
  AND license_short_name = 'CC BY 3.0'
  AND dicom_curated.BodyPartExamined = 'MEDIASTINUM'
GROUP BY
  SeriesInstanceUID