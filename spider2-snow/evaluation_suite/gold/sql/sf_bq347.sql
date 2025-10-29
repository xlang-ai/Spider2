WITH "TARGET_SERIES" AS (
    SELECT '1.3.6.1.4.1.14519.5.2.1.3671.4754.105976129314091491952445656147' AS "SeriesInstanceUID"
    UNION
    SELECT DISTINCT "SeriesInstanceUID"
    FROM "IDC"."IDC_V17"."SEGMENTATIONS"
    WHERE "segmented_SeriesInstanceUID" = '1.3.6.1.4.1.14519.5.2.1.3671.4754.105976129314091491952445656147'
),
"COUNTS" AS (
    SELECT
        "Modality",
        COUNT(*) AS "SOP_Instance_Count"
    FROM "IDC"."IDC_V17"."DICOM_ALL"
    WHERE "SeriesInstanceUID" IN (
        SELECT "SeriesInstanceUID" FROM "TARGET_SERIES"
    )
    GROUP BY "Modality"
)
SELECT "Modality", "SOP_Instance_Count"
FROM "COUNTS"
QUALIFY ROW_NUMBER() OVER (ORDER BY "SOP_Instance_Count" DESC, "Modality") = 1