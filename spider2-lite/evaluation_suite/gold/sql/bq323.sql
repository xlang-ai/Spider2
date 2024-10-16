WITH temp_query AS (
  SELECT DISTINCT
    SeriesInstanceUID,
    StudyInstanceUID,
    PatientID,
    RepetitionTime,
    EchoTime,
    SliceThickness,
    MagneticFieldStrength,
    PixelSpacing[SAFE_OFFSET(0)] AS PixelSpacing,
    CASE
      WHEN SeriesDescription LIKE '%t2_tse_tra%' AND collection_id = 'prostatex' AND Modality = 'MR' THEN 't2w_prostateX' 
      WHEN SeriesDescription LIKE '%ADC%' AND collection_id = 'prostatex' AND Modality = 'MR' THEN 'adc_prostateX'
      ELSE CONCAT(SeriesDescription, collection_id, Modality)
    END AS collection_sequence_id
  FROM 
    `spider2-public-data.idc_v17.dicom_all`
  WHERE 
    collection_id = 'prostatex'
),

averages AS (
  SELECT 
    AVG(CAST(RepetitionTime AS FLOAT64)) AS avg_RepetitionTime,
    AVG(CAST(EchoTime AS FLOAT64)) AS avg_EchoTime,
    AVG(CAST(SliceThickness AS FLOAT64)) AS avg_SliceThickness
  FROM 
    temp_query
  WHERE 
    collection_sequence_id IN ('t2w_prostateX', 'adc_prostateX')
  GROUP BY collection_sequence_id
)

SELECT 
  SUM(avg_RepetitionTime + avg_EchoTime + avg_SliceThickness) AS total_avg_time
FROM 
  averages;