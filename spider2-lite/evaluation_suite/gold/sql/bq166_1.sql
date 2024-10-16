WITH copy AS (
  SELECT case_barcode, chromosome, start_pos, end_pos, MAX(copy_number) as copy_number
  FROM `spider2-public-data.TCGA_versioned.copy_number_segment_allelic_hg38_gdc_r23`
  WHERE project_short_name = 'TCGA-KIRC'
  GROUP BY case_barcode, chromosome, start_pos, end_pos
),
total_cases AS (
  SELECT COUNT(DISTINCT case_barcode) as total
  FROM copy 
),
cytob AS (
  SELECT chromosome, cytoband_name, hg38_start, hg38_stop
  FROM `mitelman-db.prod.CytoBands_hg38`
),
joined AS (
  SELECT cytob.chromosome, cytoband_name, case_barcode, copy_number
  FROM copy
  LEFT JOIN cytob ON cytob.chromosome = copy.chromosome
  WHERE (cytob.hg38_start >= copy.start_pos AND copy.end_pos >= cytob.hg38_start)
    OR (copy.start_pos >= cytob.hg38_start AND copy.start_pos <= cytob.hg38_stop)
),
cbands AS(
  SELECT chromosome, cytoband_name, case_barcode, MAX(copy_number) as copy_number
  FROM joined
  GROUP BY chromosome, cytoband_name, case_barcode
),
aberrations AS (
  SELECT
    cytoband_name,
    SUM(IF(copy_number > 3, 1, 0)) AS total_amp,
    SUM(IF(copy_number = 3, 1, 0)) AS total_gain,
    SUM(IF(copy_number = 0, 1, 0)) AS total_homodel,
    SUM(IF(copy_number = 1, 1, 0)) AS total_heterodel,
    SUM(IF(copy_number = 2, 1, 0)) AS total_normal
  FROM cbands
  WHERE chromosome='chr1'
  GROUP BY cytoband_name
),
results AS (
  SELECT 
    cytoband_name,
    total_cases.total,
    100 * total_amp / total as freq_amp, 
    100 * total_gain / total as freq_gain,
    100 * total_heterodel / total as freq_heterodel,
    RANK() OVER (ORDER BY 100 * total_amp / total DESC) AS rank_amp,
    RANK() OVER (ORDER BY 100 * total_gain / total DESC) AS rank_gain,
    RANK() OVER (ORDER BY 100 * total_heterodel / total DESC) AS rank_heterodel
  FROM aberrations, total_cases
)
SELECT cytoband_name
FROM results
WHERE rank_amp <= 11 AND rank_gain <= 11  AND rank_heterodel <= 11