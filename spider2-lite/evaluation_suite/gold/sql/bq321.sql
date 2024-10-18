WITH relevant_series AS (
  SELECT 
    DISTINCT StudyInstanceUID
  FROM 
    `spider2-public-data.idc_v17.dicom_all`
  WHERE 
    collection_id = 'qin_prostate_repeatability'
    AND 
         SeriesDescription IN (
            'DWI',
            'T2 Weighted Axial',
            'Apparent Diffusion Coefficient',
            'T2 Weighted Axial Segmentations',
            'Apparent Diffusion Coefficient Segmentations'
    )    
),
t2_seg_lesion_series AS (
  SELECT 
    DISTINCT StudyInstanceUID
  FROM 
    `spider2-public-data.idc_v17.dicom_all`
  CROSS JOIN UNNEST(SegmentSequence) AS segSeq
  WHERE 
    collection_id = 'qin_prostate_repeatability'
    AND SeriesDescription = 'T2 Weighted Axial Segmentations'
)

SELECT 
    COUNT(DISTINCT StudyInstanceUID) AS total_count
FROM (
  SELECT 
    StudyInstanceUID 
  FROM relevant_series
  UNION ALL
  SELECT 
    StudyInstanceUID
  FROM t2_seg_lesion_series
);