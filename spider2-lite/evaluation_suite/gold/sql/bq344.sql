WITH collections_with_seg_rtstruct AS (
  SELECT
    DISTINCT(StudyInstanceUID)
  FROM
    spider2-public-data.idc_v17.dicom_all
  WHERE
    Modality = "SEG"
    OR Modality = "RTSTRUCT"
)
SELECT
  (SUM(instance_size)/POW(1024,4)) AS collection_size_TB
FROM
  bigquery-public-data.idc_v17.dicom_all AS dicom_all
JOIN
  collections_with_seg_rtstruct
ON
  dicom_all.StudyInstanceUID = collections_with_seg_rtstruct.StudyInstanceUID
GROUP BY
  collection_id
ORDER BY
  collection_size_TB DESC
LIMIT 1;