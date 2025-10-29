WITH FilteredCases AS (
    SELECT
        "case_barcode"
    FROM "TCGA_HG38_DATA_V0"."TCGA_BIOCLIN_V0"."CLINICAL"
    WHERE
        "project_short_name" = 'TCGA-BRCA'
        AND "age_at_diagnosis" <= 80
        AND "pathologic_stage" IN ('Stage I', 'Stage II', 'Stage IIA')
),
SNORA31_Expression AS (
    SELECT
        T1."case_barcode",
        LOG(10, AVG(T1."HTSeq__Counts") + 1) AS snora31_log_expr
    FROM "TCGA_HG38_DATA_V0"."TCGA_HG38_DATA_V0"."RNASEQ_GENE_EXPRESSION" AS T1
    INNER JOIN FilteredCases AS T2
        ON T1."case_barcode" = T2."case_barcode"
    WHERE
        T1."gene_name" = 'SNORA31'
    GROUP BY
        T1."case_barcode"
),
miRNA_Expression AS (
    SELECT
        T1."case_barcode",
        T1."mirna_id",
        AVG(T1."reads_per_million_miRNA_mapped") AS mirna_avg_expr
    FROM "TCGA_HG38_DATA_V0"."TCGA_HG38_DATA_V0"."MIRNASEQ_EXPRESSION" AS T1
    INNER JOIN FilteredCases AS T2
        ON T1."case_barcode" = T2."case_barcode"
    GROUP BY
        T1."case_barcode",
        T1."mirna_id"
),
CorrelationData AS (
    SELECT
        T2."mirna_id",
        CORR(T1.snora31_log_expr, T2.mirna_avg_expr) AS pearson_corr,
        COUNT(*) AS sample_count
    FROM SNORA31_Expression AS T1
    INNER JOIN miRNA_Expression AS T2
        ON T1."case_barcode" = T2."case_barcode"
    GROUP BY
        T2."mirna_id"
)
SELECT
    "mirna_id",
    pearson_corr * SQRT((sample_count - 2) / (1 - pearson_corr * pearson_corr)) AS t_statistic
FROM CorrelationData
WHERE
    sample_count > 25
    AND ABS(pearson_corr) BETWEEN 0.3 AND 1.0