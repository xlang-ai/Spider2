WITH relevant_series AS (
  SELECT 
    DISTINCT "StudyInstanceUID"
  FROM 
    IDC.IDC_V17.DICOM_ALL
  WHERE 
    "collection_id" = 'qin_prostate_repeatability'
    AND "SeriesDescription" IN (
      'DWI',
      'T2 Weighted Axial',
      'Apparent Diffusion Coefficient',
      'T2 Weighted Axial Segmentations',
      'Apparent Diffusion Coefficient Segmentations'
    )    
),
t2_seg_lesion_series AS (
  SELECT 
    DISTINCT "StudyInstanceUID"
  FROM 
    IDC.IDC_V17.DICOM_ALL
  CROSS JOIN LATERAL FLATTEN(input => "SegmentSequence") AS segSeq
  WHERE 
    "collection_id" = 'qin_prostate_repeatability'
    AND "SeriesDescription" = 'T2 Weighted Axial Segmentations'
)

SELECT 
    COUNT(DISTINCT "StudyInstanceUID") AS "total_count"
FROM (
  SELECT 
    "StudyInstanceUID" 
  FROM relevant_series
  UNION ALL
  SELECT 
    "StudyInstanceUID"
  FROM t2_seg_lesion_series
);
