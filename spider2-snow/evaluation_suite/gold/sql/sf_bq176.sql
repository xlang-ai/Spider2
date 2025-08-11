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
    "project_short_name" = 'TCGA-LAML'
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
    (ABS(cytob."hg38_stop" - cytob."hg38_start") + ABS(copy."end_pos" - copy."start_pos") 
      - ABS(cytob."hg38_stop" - copy."end_pos") - ABS(cytob."hg38_start" - copy."start_pos")) / 2.0 AS "overlap", 
    copy."copy_number"
  FROM 
    copy
  LEFT JOIN 
    cytob
  ON 
    cytob."chromosome" = copy."chromosome"
  WHERE 
    (cytob."hg38_start" >= copy."start_pos" AND copy."end_pos" >= cytob."hg38_start")
    OR (copy."start_pos" >= cytob."hg38_start" AND copy."start_pos" <= cytob."hg38_stop")
),
INFO AS (
  SELECT 
    "chromosome", 
    "cytoband_name", 
    "hg38_start", 
    "hg38_stop", 
    "case_barcode",
    ROUND(SUM("overlap" * "copy_number") / SUM("overlap")) AS "copy_number"
  FROM 
    joined
  GROUP BY 
    "chromosome", "cytoband_name", "hg38_start", "hg38_stop", "case_barcode"
)

SELECT 
  "case_barcode"
FROM 
  INFO
WHERE 
  "chromosome" = 'chr15' 
  AND "cytoband_name" = '15q11'
ORDER BY 
  "copy_number" DESC
LIMIT 1;
