WITH "kirc_total" AS (
  SELECT COUNT(DISTINCT "case_barcode") AS "total_cases"
  FROM "TCGA_MITELMAN"."TCGA_VERSIONED"."COPY_NUMBER_SEGMENT_ALLELIC_HG38_GDC_R23"
  WHERE "project_short_name" = 'TCGA-KIRC'
),
"seg_band" AS (
  SELECT
    s."case_barcode",
    s."sample_barcode",
    s."chromosome",
    b."cytoband_name",
    s."copy_number"
  FROM "TCGA_MITELMAN"."TCGA_VERSIONED"."COPY_NUMBER_SEGMENT_ALLELIC_HG38_GDC_R23" s
  JOIN "TCGA_MITELMAN"."PROD"."CYTOBANDS_HG38" b
    ON s."chromosome" = b."chromosome"
   AND LEAST(s."end_pos", b."hg38_stop") - GREATEST(s."start_pos", b."hg38_start") > 0
  WHERE s."project_short_name" = 'TCGA-KIRC'
),
"sample_band_max" AS (
  SELECT
    "case_barcode",
    "sample_barcode",
    "chromosome",
    "cytoband_name",
    MAX("copy_number") AS "sample_max_copy"
  FROM "seg_band"
  GROUP BY "case_barcode", "sample_barcode", "chromosome", "cytoband_name"
),
"case_band_max" AS (
  SELECT
    "case_barcode",
    "chromosome",
    "cytoband_name",
    MAX("sample_max_copy") AS "case_max_copy"
  FROM "sample_band_max"
  GROUP BY "case_barcode", "chromosome", "cytoband_name"
),
"case_band_category" AS (
  SELECT
    "case_barcode",
    "chromosome",
    "cytoband_name",
    CASE
      WHEN "case_max_copy" > 3 THEN 'Amplification'
      WHEN "case_max_copy" = 3 THEN 'Gain'
      WHEN "case_max_copy" = 2 THEN 'Normal'
      WHEN "case_max_copy" = 1 THEN 'Heterozygous Deletion'
      WHEN "case_max_copy" = 0 THEN 'Homozygous Deletion'
      ELSE 'Unknown'
    END AS "category"
  FROM "case_band_max"
),
"band_counts" AS (
  SELECT
    "chromosome",
    "cytoband_name",
    SUM(CASE WHEN "category" = 'Amplification' THEN 1 ELSE 0 END) AS "n_amplification",
    SUM(CASE WHEN "category" = 'Gain' THEN 1 ELSE 0 END) AS "n_gain",
    SUM(CASE WHEN "category" = 'Homozygous Deletion' THEN 1 ELSE 0 END) AS "n_homdel",
    SUM(CASE WHEN "category" = 'Heterozygous Deletion' THEN 1 ELSE 0 END) AS "n_hetdel",
    SUM(CASE WHEN "category" = 'Normal' THEN 1 ELSE 0 END) AS "n_normal"
  FROM "case_band_category"
  GROUP BY "chromosome", "cytoband_name"
)
SELECT
  bc."chromosome",
  bc."cytoband_name",
  100.0 * bc."n_amplification" / kt."total_cases" AS "amplification_pct",
  100.0 * bc."n_gain" / kt."total_cases" AS "gain_pct",
  100.0 * bc."n_homdel" / kt."total_cases" AS "homozygous_deletion_pct",
  100.0 * bc."n_hetdel" / kt."total_cases" AS "heterozygous_deletion_pct",
  100.0 * bc."n_normal" / kt."total_cases" AS "normal_pct"
FROM "band_counts" bc
CROSS JOIN "kirc_total" kt
ORDER BY
  CASE
    WHEN REGEXP_LIKE(REGEXP_REPLACE(bc."chromosome", '^chr', ''), '^[0-9]+$')
      THEN TO_NUMBER(REGEXP_REPLACE(bc."chromosome", '^chr', ''))
    WHEN REGEXP_REPLACE(bc."chromosome", '^chr', '') = 'X' THEN 23
    WHEN REGEXP_REPLACE(bc."chromosome", '^chr', '') = 'Y' THEN 24
    ELSE 25
  END,
  bc."cytoband_name";