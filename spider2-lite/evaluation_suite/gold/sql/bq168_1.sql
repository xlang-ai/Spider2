WITH copy AS (
  SELECT case_barcode,        #sample_barcode,        aliquot_barcode, 
    chromosome,        start_pos,        end_pos,        MAX(copy_number) as copy_number
  FROM `spider2-public-data.TCGA_versioned.copy_number_segment_allelic_hg38_gdc_r23` 
  WHERE  project_short_name = 'TCGA-LAML'
  GROUP BY case_barcode, chromosome,        start_pos,        end_pos
),
total_cases AS (
  SELECT COUNT( DISTINCT case_barcode) as total
  FROM copy 
),
cytob AS (
  SELECT chromosome, cytoband_name, hg38_start, hg38_stop,
  FROM mitelman-db.prod.CytoBands_hg38
),
joined AS (
  SELECT cytob.chromosome, cytoband_name, hg38_start, hg38_stop,
    case_barcode,
    ( ABS(hg38_stop - hg38_start) + ABS(end_pos - start_pos) 
      - ABS(hg38_stop - end_pos) - ABS(hg38_start - start_pos) )/2.0  AS overlap ,
    copy_number  
  FROM copy
  LEFT JOIN cytob
  ON cytob.chromosome = copy.chromosome 
  WHERE 
    ( cytob.hg38_start >= copy.start_pos AND copy.end_pos >= cytob.hg38_start )
    OR ( copy.start_pos >= cytob.hg38_start  AND  copy.start_pos <= cytob.hg38_stop )
),
INFO AS (
SELECT chromosome, cytoband_name, hg38_start, hg38_stop, case_barcode,
    ROUND( SUM(overlap*copy_number) / SUM(overlap) ) as copy_number
FROM joined
GROUP BY 
   chromosome, cytoband_name, hg38_start, hg38_stop, case_barcode
)

SELECT case_barcode
FROM INFO
WHERE
chromosome = 'chr15' AND cytoband_name = '15q11'
ORDER BY copy_number
DESC
LIMIT 1