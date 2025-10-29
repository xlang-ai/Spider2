/*
Goal: Identify TCGA-LAML case barcodes with the highest weighted average copy number 
      inside cytoband 15q11 (chr15:19,000,000-25,500,000 on hg38).
      ‑ Use cytoband coordinates from CYTOBANDS_HG38.
      ‑ Use segment-level copy number from COPY_NUMBER_SEGMENT_ALLELIC_HG38_GDC_R23 
        (this table stores integer "copy_number" values and chromosome names like 'chr15').
      ‑ Weighted average =  Σ(copy_number * overlap_length) / Σ(overlap_length),
        where overlap_length is the number of bases of a segment that fall inside 15q11.
      ‑ Return the barcode(s) whose weighted average equals the global maximum.
*/

WITH band AS (
    /* Exact genomic span of cytoband 15q11 on chr15 (hg38) */
    SELECT 
        MIN("hg38_start") AS "region_start",
        MAX("hg38_stop")  AS "region_end"
    FROM "TCGA_MITELMAN"."PROD"."CYTOBANDS_HG38"
    WHERE "cytoband_name" ILIKE '15q11%'      -- include 15q11, 15q11.1, 15q11.2, ...
      AND "chromosome" = 'chr15'
), laml_segments AS (
    /* All chr15 copy-number segments for TCGA-LAML cases (hg38, allelic table) */
    SELECT 
        s."case_barcode",
        s."start_pos",
        s."end_pos",
        s."copy_number"
    FROM "TCGA_MITELMAN"."TCGA_VERSIONED"."COPY_NUMBER_SEGMENT_ALLELIC_HG38_GDC_R23" s
    WHERE s."project_short_name" = 'TCGA-LAML'
      AND s."chromosome" = 'chr15'
), overlaps AS (
    /* Keep only segment portions that actually overlap 15q11 */
    SELECT 
        l."case_barcode",
        GREATEST(l."start_pos", b."region_start") AS "ov_start",
        LEAST(l."end_pos",   b."region_end")   AS "ov_end",
        l."copy_number"
    FROM laml_segments l
    CROSS JOIN band b
    WHERE l."end_pos"   >= b."region_start"   -- segment starts before region end
      AND l."start_pos" <= b."region_end"     -- segment ends after region start
), weighted AS (
    /* Compute weighted sums per case */
    SELECT 
        "case_barcode",
        SUM( ("ov_end" - "ov_start" + 1) * "copy_number" ) AS "weighted_sum",
        SUM(  "ov_end" - "ov_start" + 1 )                  AS "total_len"
    FROM overlaps
    GROUP BY "case_barcode"
), per_case AS (
    /* Final weighted average copy number per case */
    SELECT 
        "case_barcode",
        "weighted_sum" / "total_len" AS "weighted_avg_copy_number"
    FROM weighted
)
/* Return the barcode(s) with the highest weighted average */
SELECT "case_barcode"
FROM per_case
WHERE "weighted_avg_copy_number" = (
    SELECT MAX("weighted_avg_copy_number") FROM per_case
)
ORDER BY "case_barcode";