WITH
  nonLocalizerRawData AS (
    SELECT
      "SeriesInstanceUID",
      "StudyInstanceUID",
      "PatientID",
      TRY_CAST("Exposure"::STRING AS FLOAT) AS "Exposure",  -- 直接从 bid 获取 Exposure
      TRY_CAST(axes.VALUE::STRING AS FLOAT) AS "zImagePosition",
      LEAD(TRY_CAST(axes.VALUE::STRING AS FLOAT)) OVER (
        PARTITION BY "SeriesInstanceUID" 
        ORDER BY TRY_CAST(axes.VALUE::STRING AS FLOAT)
      ) - TRY_CAST(axes.VALUE::STRING AS FLOAT) AS "slice_interval",
      "instance_size" AS "instanceSize"
    FROM
      "IDC"."IDC_V17"."DICOM_ALL" AS "bid",
      LATERAL FLATTEN(input => "bid"."ImagePositionPatient") AS axes  -- 使用 LATERAL FLATTEN 展开数组
    WHERE
      "collection_id" = 'nlst' 
      AND "Modality" = 'CT' 
  ),
  geometryChecks AS (
    SELECT
      "SeriesInstanceUID",
      "StudyInstanceUID",
      "PatientID",
      ARRAY_AGG(DISTINCT "slice_interval") AS "sliceIntervalDifferences",
      ARRAY_AGG(DISTINCT "Exposure") AS "distinctExposures",
      SUM("instanceSize") / 1024 / 1024 AS "seriesSizeInMB"
    FROM
      nonLocalizerRawData
    GROUP BY
      "SeriesInstanceUID", 
      "StudyInstanceUID",
      "PatientID"
  ),
  patientMetrics AS (
    SELECT
      "PatientID",
      MAX(TRY_CAST(sid.VALUE::STRING AS FLOAT)) AS "maxSliceIntervalDifference",
      MIN(TRY_CAST(sid.VALUE::STRING AS FLOAT)) AS "minSliceIntervalDifference",
      MAX(TRY_CAST(sid.VALUE::STRING AS FLOAT)) - MIN(TRY_CAST(sid.VALUE::STRING AS FLOAT)) AS "sliceIntervalDifferenceTolerance",
      MAX(TRY_CAST(de.VALUE::STRING AS FLOAT)) AS "maxExposure",
      MIN(TRY_CAST(de.VALUE::STRING AS FLOAT)) AS "minExposure",
      MAX(TRY_CAST(de.VALUE::STRING AS FLOAT)) - MIN(TRY_CAST(de.VALUE::STRING AS FLOAT)) AS "maxExposureDifference",
      "seriesSizeInMB"
    FROM
      geometryChecks,
      LATERAL FLATTEN(input => "sliceIntervalDifferences") AS sid,  -- 展开 sliceIntervalDifferences
      LATERAL FLATTEN(input => "distinctExposures") AS de  -- 展开 distinctExposures
    WHERE
      sid.VALUE IS NOT NULL
      AND de.VALUE IS NOT NULL
    GROUP BY
      "PatientID",
      "seriesSizeInMB"
  ),
  top3BySliceInterval AS (
    SELECT
      "PatientID",
      "seriesSizeInMB"
    FROM
      patientMetrics
    ORDER BY
      "sliceIntervalDifferenceTolerance" DESC
    LIMIT 3
  ),
  top3ByMaxExposure AS (
    SELECT
      "PatientID",
      "seriesSizeInMB"
    FROM
      patientMetrics
    ORDER BY
      "maxExposureDifference" DESC
    LIMIT 3
  )
SELECT
  'Top 3 by Slice Interval' AS "MetricGroup",
  AVG("seriesSizeInMB") AS "AverageSeriesSizeInMB"
FROM
  top3BySliceInterval
UNION ALL
SELECT
  'Top 3 by Max Exposure' AS "MetricGroup",
  AVG("seriesSizeInMB") AS "AverageSeriesSizeInMB"
FROM
  top3ByMaxExposure;
