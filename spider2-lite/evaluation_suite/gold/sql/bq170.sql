WITH copy AS (
    SELECT
        case_barcode,
        chromosome,
        start_pos,
        end_pos,
        MAX(copy_number) as copy_number
    FROM `spider2-public-data.TCGA_versioned.copy_number_segment_allelic_hg38_gdc_r23` 
    WHERE  project_short_name = 'TCGA-BRCA'
    GROUP BY case_barcode, chromosome, start_pos, end_pos
),
total_cases AS (
    SELECT COUNT(DISTINCT case_barcode) as total
    FROM copy 
),
cytob AS (
    SELECT chromosome, cytoband_name, hg38_start, hg38_stop,
    FROM mitelman-db.prod.CytoBands_hg38
),
joined AS (
    SELECT
        cytob.chromosome,
        cytoband_name,
        hg38_start,
        hg38_stop,
        case_barcode,
        (ABS(hg38_stop - hg38_start) + ABS(end_pos - start_pos) 
        - ABS(hg38_stop - end_pos) - ABS(hg38_start - start_pos)) / 2.0  AS overlap,
        copy_number
    FROM copy
    LEFT JOIN cytob
    ON cytob.chromosome = copy.chromosome 
    WHERE 
        ( cytob.hg38_start >= copy.start_pos AND copy.end_pos >= cytob.hg38_start )
        OR ( copy.start_pos >= cytob.hg38_start  AND  copy.start_pos <= cytob.hg38_stop )
),
cbands AS(
    SELECT chromosome, cytoband_name, hg38_start, hg38_stop, case_barcode,
        ROUND( SUM(overlap * copy_number) / SUM(overlap) ) as copy_number
    FROM joined
    GROUP BY 
    chromosome, cytoband_name, hg38_start, hg38_stop, case_barcode
),
aberrations AS (
  SELECT
    chromosome,
    cytoband_name,
    hg38_start,
    hg38_stop,
    SUM( IF( copy_number = 0, 1, 0) ) AS total_homodel,
    SUM( IF( copy_number = 1, 1, 0) ) AS total_heterodel,
    SUM( IF( copy_number = 2, 1, 0) )  AS total_normal,
    SUM( IF( copy_number = 3 ,1, 0) ) AS total_gain,
    SUM( IF (copy_number > 3 , 1 , 0) ) AS total_amp

  FROM cbands
  GROUP BY chromosome, cytoband_name, hg38_start, hg38_stop
),
tcga AS (
    SELECT
        chromosome, cytoband_name, hg38_start, hg38_stop,
        total,  
        ROUND(100 * total_homodel/ total, 2) as freq_homodel, 
        ROUND(100 * total_heterodel / total, 2)as freq_heterodel, 
        ROUND(100 * total_normal / total, 2) as freq_normal,
        ROUND(100 * total_gain / total, 2) as freq_gain,
        ROUND(100 * total_amp / total, 2)as freq_amp
    FROM aberrations, total_cases
    ORDER BY chromosome, hg38_start, hg38_stop
)
SELECT cytoband_name, hg38_start, hg38_stop, freq_homodel, freq_heterodel, freq_normal, freq_gain, freq_amp
FROM tcga;