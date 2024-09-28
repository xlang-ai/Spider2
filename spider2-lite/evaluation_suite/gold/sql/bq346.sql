WITH
  sampled_sops AS (
    SELECT
      collection_id,
      SeriesDescription,
      SeriesInstanceUID,
      SOPInstanceUID AS seg_SOPInstanceUID,
      COALESCE(
        ReferencedSeriesSequence[SAFE_OFFSET(0)].ReferencedInstanceSequence[SAFE_OFFSET(0)].ReferencedSOPInstanceUID,
        ReferencedImageSequence[SAFE_OFFSET(0)].ReferencedSOPInstanceUID,
        SourceImageSequence[SAFE_OFFSET(0)].ReferencedSOPInstanceUID
      ) AS referenced_sop
    FROM
      `bigquery-public-data.idc_v17.dicom_all`
    WHERE
      Modality = "SEG"
      AND SOPClassUID = "1.2.840.10008.5.1.4.1.1.66.4"
      AND Access = "Public"
  ),
  segmentations_data AS (
    SELECT
      dicom_all.collection_id,
      dicom_all.PatientID,
      dicom_all.SOPInstanceUID,
      segmentations.SegmentedPropertyCategory.CodeMeaning AS segmentation_category,
      segmentations.SegmentedPropertyType.CodeMeaning AS segmentation_type
    FROM
      sampled_sops
    JOIN
      `bigquery-public-data.idc_v17.dicom_all` AS dicom_all
    ON
      sampled_sops.referenced_sop = dicom_all.SOPInstanceUID
    JOIN
      `bigquery-public-data.idc_v17.segmentations` AS segmentations
    ON
      segmentations.SOPInstanceUID = sampled_sops.seg_SOPInstanceUID
  )
SELECT
  segmentation_category,
  COUNT(*) AS count_
FROM
  segmentations_data
GROUP BY
  segmentation_category
ORDER BY
  count_ DESC
LIMIT 5;