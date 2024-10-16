WITH
  nonLocalizerRawData AS (
    SELECT
      SeriesInstanceUID,
      StudyInstanceUID,
      PatientID,
      SAFE_CAST(Exposure AS FLOAT64) AS Exposure,
      SAFE_CAST(ipp AS FLOAT64) AS zImagePosition,
      LEAD(SAFE_CAST(ipp AS FLOAT64)) OVER (PARTITION BY SeriesInstanceUID ORDER BY SAFE_CAST(ipp AS FLOAT64)) - SAFE_CAST(ipp AS FLOAT64) AS slice_interval,
      instance_size AS instanceSize  -- Ensure instanceSize is included here
    FROM
      `spider2-public-data.idc_v17.dicom_all` bid
    LEFT JOIN
      UNNEST(bid.ImagePositionPatient) ipp WITH OFFSET AS axes
    WHERE
      collection_id = 'nlst' 
      AND Modality = 'CT' 
  ),
  geometryChecks AS (
    SELECT
      SeriesInstanceUID,
      StudyInstanceUID,
      PatientID,
      ARRAY_AGG(DISTINCT slice_interval IGNORE NULLS) AS sliceIntervalDifferences,
      ARRAY_AGG(DISTINCT Exposure IGNORE NULLS) AS distinctExposures,
      SUM(instanceSize) / 1024 / 1024 AS seriesSizeInMB
    FROM
      nonLocalizerRawData
    GROUP BY
      SeriesInstanceUID, 
      StudyInstanceUID,
      PatientID
  ),
  patientMetrics AS (
    SELECT
      PatientID,
      MAX(sid) AS maxSliceIntervalDifference,
      MIN(sid) AS minSliceIntervalDifference,
      MAX(sid) - MIN(sid) AS sliceIntervalDifferenceTolerance,
      MAX(de) AS maxExposure,
      MIN(de) AS minExposure,
      MAX(de) - MIN(de) AS maxExposureDifference,
      seriesSizeInMB
    FROM
      geometryChecks
    LEFT JOIN
      UNNEST(sliceIntervalDifferences) AS sid
    LEFT JOIN
      UNNEST(distinctExposures) AS de
    WHERE
      sid IS NOT NULL
      AND de IS NOT NULL
    GROUP BY
      PatientID,
      seriesSizeInMB
  ),
  top3BySliceInterval AS (
    SELECT
      PatientID,
      seriesSizeInMB
    FROM
      patientMetrics
    ORDER BY
      sliceIntervalDifferenceTolerance DESC
    LIMIT 3
  ),
  top3ByMaxExposure AS (
    SELECT
      PatientID,
      seriesSizeInMB
    FROM
      patientMetrics
    ORDER BY
      maxExposureDifference DESC
    LIMIT 3
  )
SELECT
  'Top 3 by Slice Interval' AS MetricGroup,
  AVG(seriesSizeInMB) AS AverageSeriesSizeInMB
FROM
  top3BySliceInterval
UNION ALL
SELECT
  'Top 3 by Max Exposure' AS MetricGroup,
  AVG(seriesSizeInMB) AS AverageSeriesSizeInMB
FROM
  top3ByMaxExposure;