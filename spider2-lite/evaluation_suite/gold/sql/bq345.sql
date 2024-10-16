WITH refs_series_counted AS (
  SELECT
    collection_id,
    SeriesInstanceUID,
    SeriesDescription,
    ARRAY_LENGTH(ReferencedSeriesSequence) AS ref_len,
    ARRAY_LENGTH(ReferencedImageSequence) AS ref_img_len,
    ARRAY_LENGTH(SourceImageSequence) AS src_img_len,
    CONCAT("https://viewer.imaging.datacommons.cancer.gov/viewer/", StudyInstanceUID) AS viewer_url
  FROM
    `spider2-public-data.idc_v17.dicom_all`
  WHERE
    Modality = "SEG"
    AND SOPClassUID = "1.2.840.10008.5.1.4.1.1.66.4"
)
SELECT
  COUNT(DISTINCT(collection_id)) AS distinct_collection_count
FROM
  refs_series_counted
WHERE
  ref_len = 0
  AND ref_img_len = 0
  AND src_img_len = 0;