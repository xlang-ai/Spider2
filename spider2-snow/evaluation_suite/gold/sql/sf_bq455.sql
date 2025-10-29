SELECT
    sm."SeriesInstanceUID",
    sm."SeriesNumber",
    sm."PatientID",
    sm."series_size_mib"
FROM (
    SELECT
        wd."SeriesInstanceUID",
        MIN(wd."SeriesNumber") AS "SeriesNumber",
        MIN(wd."PatientID") AS "PatientID",
        SUM(wd."instance_size") / 1048576.0 AS "series_size_mib",
        COUNT(*) AS "image_count",
        COUNT(DISTINCT wd."pos_z_r") AS "unique_z_count",
        COUNT(DISTINCT wd."pos_xy_key") AS "unique_xy_count",
        COUNT(DISTINCT wd."ps_row_r") AS "ps_row_count",
        COUNT(DISTINCT wd."ps_col_r") AS "ps_col_count",
        COUNT(DISTINCT wd."Rows") AS "rows_count",
        COUNT(DISTINCT wd."Columns") AS "cols_count",
        COUNT(DISTINCT wd."orientation_raw") AS "orientation_count",
        COUNT(DISTINCT wd."exposure_inmas_r") AS "exposure_inmas_count",
        COUNT(DISTINCT wd."exposure_r") AS "exposure_count",
        COUNT(DISTINCT wd."tube_current_r") AS "tube_current_count",
        COUNT(DISTINCT CASE WHEN wd."z_diff" IS NOT NULL THEN wd."z_diff" END) AS "distinct_z_diff_count",
        MIN(wd."z_diff") AS "min_z_diff",
        MAX(wd."z_diff") AS "max_z_diff",
        MIN(wd."cross_z") AS "min_cross_z",
        MAX(wd."cross_z") AS "max_cross_z"
    FROM (
        SELECT
            f."SeriesInstanceUID",
            f."SeriesNumber",
            f."PatientID",
            f."instance_size",
            CONCAT(TO_VARCHAR(f."pos_x_r"), '|', TO_VARCHAR(f."pos_y_r")) AS "pos_xy_key",
            f."pos_z",
            f."pos_z_r",
            f."ps_row_r",
            f."ps_col_r",
            f."Rows",
            f."Columns",
            f."orientation_raw",
            f."exposure_inmas_r",
            f."exposure_r",
            f."tube_current_r",
            f."cross_z",
            ROUND(ABS(LEAD(f."pos_z") OVER (PARTITION BY f."SeriesInstanceUID" ORDER BY f."pos_z") - f."pos_z"), 5) AS "z_diff"
        FROM (
            SELECT
                da."SeriesInstanceUID",
                da."SeriesNumber",
                da."PatientID",
                da."instance_size",
                TRY_TO_DOUBLE(da."ImagePositionPatient"[2]::STRING) AS "pos_z",
                ROUND(TRY_TO_DOUBLE(da."ImagePositionPatient"[0]::STRING), 5) AS "pos_x_r",
                ROUND(TRY_TO_DOUBLE(da."ImagePositionPatient"[1]::STRING), 5) AS "pos_y_r",
                ROUND(TRY_TO_DOUBLE(da."ImagePositionPatient"[2]::STRING), 5) AS "pos_z_r",
                ROUND(TRY_TO_DOUBLE(da."PixelSpacing"[0]::STRING), 5) AS "ps_row_r",
                ROUND(TRY_TO_DOUBLE(da."PixelSpacing"[1]::STRING), 5) AS "ps_col_r",
                da."Rows",
                da."Columns",
                TO_VARCHAR(da."ImageOrientationPatient") AS "orientation_raw",
                ROUND(TRY_TO_DOUBLE(da."ExposureInmAs"::STRING), 4) AS "exposure_inmas_r",
                ROUND(TRY_TO_DOUBLE(da."Exposure"::STRING), 4) AS "exposure_r",
                ROUND(TRY_TO_DOUBLE(da."XRayTubeCurrentInmA"::STRING), 4) AS "tube_current_r",
                TRY_TO_DOUBLE(da."ImageOrientationPatient"[0]::STRING) * TRY_TO_DOUBLE(da."ImageOrientationPatient"[4]::STRING)
                  - TRY_TO_DOUBLE(da."ImageOrientationPatient"[1]::STRING) * TRY_TO_DOUBLE(da."ImageOrientationPatient"[3]::STRING) AS "cross_z"
            FROM "IDC"."IDC_V17"."DICOM_ALL" da
            WHERE NVL(UPPER(da."collection_name"), '') != 'NLST'
              AND da."Modality" = 'CT'
              AND da."TransferSyntaxUID" NOT IN ('1.2.840.10008.1.2.4.70', '1.2.840.10008.1.2.4.51')
              AND NOT (UPPER(TO_VARCHAR(da."ImageType")) LIKE '%LOCALIZER%')
              AND da."SeriesInstanceUID" IS NOT NULL
              AND da."SeriesNumber" IS NOT NULL
              AND da."PatientID" IS NOT NULL
              AND da."ImagePositionPatient" IS NOT NULL
              AND da."ImageOrientationPatient" IS NOT NULL
              AND da."PixelSpacing" IS NOT NULL
              AND TRY_TO_DOUBLE(da."ImagePositionPatient"[0]::STRING) IS NOT NULL
              AND TRY_TO_DOUBLE(da."ImagePositionPatient"[1]::STRING) IS NOT NULL
              AND TRY_TO_DOUBLE(da."ImagePositionPatient"[2]::STRING) IS NOT NULL
              AND TRY_TO_DOUBLE(da."PixelSpacing"[0]::STRING) IS NOT NULL
              AND TRY_TO_DOUBLE(da."PixelSpacing"[1]::STRING) IS NOT NULL
              AND TRY_TO_DOUBLE(da."ImageOrientationPatient"[0]::STRING) IS NOT NULL
              AND TRY_TO_DOUBLE(da."ImageOrientationPatient"[1]::STRING) IS NOT NULL
              AND TRY_TO_DOUBLE(da."ImageOrientationPatient"[3]::STRING) IS NOT NULL
              AND TRY_TO_DOUBLE(da."ImageOrientationPatient"[4]::STRING) IS NOT NULL
        ) f
    ) wd
    GROUP BY wd."SeriesInstanceUID"
) sm
WHERE sm."image_count" = sm."unique_z_count"
  AND sm."unique_xy_count" = 1
  AND sm."ps_row_count" = 1
  AND sm."ps_col_count" = 1
  AND sm."rows_count" = 1
  AND sm."cols_count" = 1
  AND sm."orientation_count" = 1
  AND sm."distinct_z_diff_count" <= 1
  AND (sm."distinct_z_diff_count" = 0 OR sm."min_z_diff" = sm."max_z_diff")
  AND sm."exposure_inmas_count" <= 1
  AND sm."exposure_count" <= 1
  AND sm."tube_current_count" <= 1
  AND ABS(sm."min_cross_z") BETWEEN 0.99 AND 1.01
  AND ABS(sm."max_cross_z") BETWEEN 0.99 AND 1.01
ORDER BY sm."series_size_mib" DESC
LIMIT 5;