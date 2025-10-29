WITH f AS (
  SELECT
    "PatientID",
    "SeriesInstanceUID",
    "instance_size",
    "SpacingBetweenSlices",
    "SliceThickness",
    "Exposure",
    "ExposureInmAs",
    "Modality",
    "collection_name"
  FROM "IDC"."IDC_V17"."DICOM_ALL"
  WHERE UPPER("collection_name") = 'NLST'
    AND "Modality" = 'CT'
),
series_sizes AS (
  SELECT
    "PatientID",
    "SeriesInstanceUID",
    SUM(COALESCE("instance_size", 0))::FLOAT / (1024 * 1024) AS series_size_mib
  FROM f
  GROUP BY "PatientID", "SeriesInstanceUID"
),
patient_slice_intervals AS (
  SELECT DISTINCT
    "PatientID",
    COALESCE(TRY_TO_DECIMAL("SpacingBetweenSlices"), TRY_TO_DECIMAL("SliceThickness")) AS slice_interval
  FROM f
  WHERE COALESCE(TRY_TO_DECIMAL("SpacingBetweenSlices"), TRY_TO_DECIMAL("SliceThickness")) IS NOT NULL
),
patient_slice_diff AS (
  SELECT
    "PatientID",
    MAX(slice_interval) - MIN(slice_interval) AS slice_diff
  FROM patient_slice_intervals
  GROUP BY "PatientID"
),
top3_by_slice AS (
  SELECT "PatientID"
  FROM patient_slice_diff
  ORDER BY slice_diff DESC NULLS LAST
  LIMIT 3
),
patient_exposure_values AS (
  SELECT DISTINCT
    "PatientID",
    COALESCE(CAST("ExposureInmAs" AS FLOAT), CAST(TRY_TO_DECIMAL("Exposure") AS FLOAT)) AS exposure_val
  FROM f
  WHERE COALESCE(CAST("ExposureInmAs" AS FLOAT), CAST(TRY_TO_DECIMAL("Exposure") AS FLOAT)) IS NOT NULL
),
patient_exposure_diff AS (
  SELECT
    "PatientID",
    MAX(exposure_val) - MIN(exposure_val) AS exp_diff
  FROM patient_exposure_values
  GROUP BY "PatientID"
),
top3_by_exposure AS (
  SELECT "PatientID"
  FROM patient_exposure_diff
  ORDER BY exp_diff DESC NULLS LAST
  LIMIT 3
)
SELECT 'Top 3 by Slice Interval' AS "Label",
       AVG(s.series_size_mib) AS "Average Series Size MiB"
FROM series_sizes s
JOIN top3_by_slice t USING ("PatientID")
UNION ALL
SELECT 'Top 3 by Max Exposure' AS "Label",
       AVG(s.series_size_mib) AS "Average Series Size MiB"
FROM series_sizes s
JOIN top3_by_exposure t USING ("PatientID");