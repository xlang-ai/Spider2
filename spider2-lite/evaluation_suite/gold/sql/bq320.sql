SELECT
  COUNT(*) AS total_count
FROM
  `spider2-public-data.idc_v17.dicom_pivot` dicom_pivot
WHERE
  StudyInstanceUID IN (
    SELECT
      StudyInstanceUID
    FROM
      `spider2-public-data.idc_v17.dicom_pivot` dicom_pivot
    WHERE
      StudyInstanceUID IN (
        SELECT
          StudyInstanceUID
        FROM
          `spider2-public-data.idc_v17.dicom_pivot` dicom_pivot
        WHERE
          (
            LOWER(
              dicom_pivot.SegmentedPropertyTypeCodeSequence
            ) LIKE LOWER('15825003')
          )
        GROUP BY
          StudyInstanceUID
        INTERSECT DISTINCT
        SELECT
          StudyInstanceUID
        FROM
          `spider2-public-data.idc_v17.dicom_pivot` dicom_pivot
        WHERE
          (
            dicom_pivot.collection_id IN ('Community', 'nsclc_radiomics')
          )
        GROUP BY
          StudyInstanceUID
      )
    GROUP BY
      StudyInstanceUID
  );
  