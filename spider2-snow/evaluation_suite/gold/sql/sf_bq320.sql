SELECT
  COUNT(*) AS "total_count"
FROM
  IDC.IDC_V17.DICOM_PIVOT AS "dicom_pivot"
WHERE
  "StudyInstanceUID" IN (
    SELECT
      "StudyInstanceUID"
    FROM
      IDC.IDC_V17.DICOM_PIVOT AS "dicom_pivot"
    WHERE
      "StudyInstanceUID" IN (
        SELECT
          "StudyInstanceUID"
        FROM
          IDC.IDC_V17.DICOM_PIVOT AS "dicom_pivot"
        WHERE
          LOWER("dicom_pivot"."SegmentedPropertyTypeCodeSequence") LIKE LOWER('15825003')
        GROUP BY
          "StudyInstanceUID"
        INTERSECT
        SELECT
          "StudyInstanceUID"
        FROM
          IDC.IDC_V17.DICOM_PIVOT AS "dicom_pivot"
        WHERE
          "dicom_pivot"."collection_id" IN ('Community', 'nsclc_radiomics')
        GROUP BY
          "StudyInstanceUID"
      )
    GROUP BY
      "StudyInstanceUID"
  );
