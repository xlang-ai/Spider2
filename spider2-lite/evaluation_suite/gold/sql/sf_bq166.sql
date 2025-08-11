WITH copy AS (
  SELECT 
    "case_barcode", 
    "chromosome", 
    "start_pos", 
    "end_pos", 
    MAX("copy_number") AS "copy_number"
  FROM 
    "TCGA_MITELMAN"."TCGA_VERSIONED"."COPY_NUMBER_SEGMENT_ALLELIC_HG38_GDC_R23" 
  WHERE  
    "project_short_name" = 'TCGA-KIRC'
  GROUP BY 
    "case_barcode", 
    "chromosome", 
    "start_pos", 
    "end_pos"
),
total_cases AS (
  SELECT COUNT(DISTINCT "case_barcode") AS "total"
  FROM copy 
),
cytob AS (
  SELECT 
    "chromosome", 
    "cytoband_name", 
    "hg38_start", 
    "hg38_stop"
  FROM 
    "TCGA_MITELMAN"."PROD"."CYTOBANDS_HG38"
),
joined AS (
  SELECT 
    cytob."chromosome", 
    cytob."cytoband_name", 
    cytob."hg38_start", 
    cytob."hg38_stop",
    copy."case_barcode",
    copy."copy_number"  
  FROM 
    copy
  LEFT JOIN cytob
    ON cytob."chromosome" = copy."chromosome" 
  WHERE 
    (cytob."hg38_start" >= copy."start_pos" AND copy."end_pos" >= cytob."hg38_start")
    OR (copy."start_pos" >= cytob."hg38_start" AND copy."start_pos" <= cytob."hg38_stop")
),
cbands AS (
  SELECT 
    "chromosome", 
    "cytoband_name", 
    "hg38_start", 
    "hg38_stop", 
    "case_barcode",
    MAX("copy_number") AS "copy_number"
  FROM 
    joined
  GROUP BY 
    "chromosome", 
    "cytoband_name", 
    "hg38_start", 
    "hg38_stop", 
    "case_barcode"
),
aberrations AS (
  SELECT
    "chromosome",
    "cytoband_name",
    -- Amplifications: more than two copies for diploid > 4
    SUM( CASE WHEN "copy_number" > 3 THEN 1 ELSE 0 END ) AS "total_amp",
    -- Gains: at most two extra copies
    SUM( CASE WHEN "copy_number" = 3 THEN 1 ELSE 0 END ) AS "total_gain",
    -- Homozygous deletions, or complete deletions
    SUM( CASE WHEN "copy_number" = 0 THEN 1 ELSE 0 END ) AS "total_homodel",
    -- Heterozygous deletions, 1 copy lost
    SUM( CASE WHEN "copy_number" = 1 THEN 1 ELSE 0 END ) AS "total_heterodel",
    -- Normal for Diploid = 2
    SUM( CASE WHEN "copy_number" = 2 THEN 1 ELSE 0 END ) AS "total_normal"
  FROM 
    cbands
  GROUP BY 
    "chromosome", 
    "cytoband_name"
)
SELECT 
  aberrations."chromosome", 
  aberrations."cytoband_name",
  total_cases."total",  
  100 * aberrations."total_amp" / total_cases."total" AS "freq_amp", 
  100 * aberrations."total_gain" / total_cases."total" AS "freq_gain",
  100 * aberrations."total_homodel" / total_cases."total" AS "freq_homodel", 
  100 * aberrations."total_heterodel" / total_cases."total" AS "freq_heterodel", 
  100 * aberrations."total_normal" / total_cases."total" AS "freq_normal"  
FROM 
  aberrations, 
  total_cases
ORDER BY 
  aberrations."chromosome", 
  aberrations."cytoband_name";
