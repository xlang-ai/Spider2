WITH "cdkn2a_cases" AS (
  SELECT DISTINCT "case_barcode"
  FROM "TCGA"."TCGA_VERSIONED"."SOMATIC_MUTATION_HG19_DCC_2017_02"
  WHERE "project_short_name" = 'TCGA-BLCA'
    AND "Hugo_Symbol" = 'CDKN2A'
    AND "Mutation_Status" = 'Somatic'
  UNION
  SELECT DISTINCT "case_barcode"
  FROM "TCGA"."TCGA_VERSIONED"."SOMATIC_MUTATION_HG19_MC3_2017_02"
  WHERE "project_short_name" = 'TCGA-BLCA'
    AND "Hugo_Symbol" = 'CDKN2A'
),
"expr_hg19" AS (
  SELECT
    e."case_barcode",
    MAX(IFF(e."HGNC_gene_symbol" = 'MDM2', e."normalized_count", NULL))   AS "MDM2_normalized_count",
    MAX(IFF(e."HGNC_gene_symbol" = 'TP53', e."normalized_count", NULL))   AS "TP53_normalized_count",
    MAX(IFF(e."HGNC_gene_symbol" = 'CDKN1A', e."normalized_count", NULL)) AS "CDKN1A_normalized_count",
    MAX(IFF(e."HGNC_gene_symbol" = 'CCNE1', e."normalized_count", NULL))  AS "CCNE1_normalized_count"
  FROM "TCGA"."TCGA_VERSIONED"."RNASEQ_HG19_GDC_2017_02" e
  WHERE e."project_short_name" = 'TCGA-BLCA'
    AND e."HGNC_gene_symbol" IN ('MDM2','TP53','CDKN1A','CCNE1')
    AND e."sample_barcode" LIKE '%-01%'  -- Primary Tumor samples
  GROUP BY e."case_barcode"
)
SELECT
  c."submitter_id" AS "case_barcode",
  e."MDM2_normalized_count",
  e."TP53_normalized_count",
  e."CDKN1A_normalized_count",
  e."CCNE1_normalized_count",
  c."proj__project_id" AS "project_id",
  c."primary_site",
  c."disease_type",
  c."demo__gender" AS "gender",
  c."demo__race" AS "race",
  c."demo__ethnicity" AS "ethnicity",
  c."demo__vital_status" AS "vital_status",
  c."diag__age_at_diagnosis" AS "age_at_diagnosis_days",
  c."diag__year_of_diagnosis" AS "year_of_diagnosis",
  c."diag__ajcc_pathologic_stage" AS "ajcc_pathologic_stage",
  c."diag__ajcc_clinical_stage" AS "ajcc_clinical_stage"
FROM "TCGA"."TCGA_VERSIONED"."CLINICAL_GDC_R39" c
JOIN "cdkn2a_cases" m
  ON c."submitter_id" = m."case_barcode"
LEFT JOIN "expr_hg19" e
  ON e."case_barcode" = c."submitter_id"
WHERE c."proj__project_id" = 'TCGA-BLCA'
ORDER BY c."submitter_id";