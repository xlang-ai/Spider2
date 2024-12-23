WITH cohort AS (
    SELECT "case_barcode"
    FROM "TCGA_HG38_DATA_V0"."TCGA_BIOCLIN_V0"."CLINICAL"
    WHERE "project_short_name" = 'TCGA-BRCA'
        AND "age_at_diagnosis" <= 80
        AND "pathologic_stage" IN ('Stage I', 'Stage II', 'Stage IIA')
),
table1 AS (
    SELECT
        "symbol",
        "data" AS "rnkdata",
        "ParticipantBarcode"
    FROM (
        SELECT
            "gene_name" AS "symbol", 
            AVG(LOG(10, "HTSeq__Counts" + 1)) AS "data",
            "case_barcode" AS "ParticipantBarcode"
        FROM "TCGA_HG38_DATA_V0"."TCGA_HG38_DATA_V0"."RNASEQ_GENE_EXPRESSION"
        WHERE "case_barcode" IN (SELECT "case_barcode" FROM cohort)
            AND "gene_name" = 'SNORA31'
            AND "HTSeq__Counts" IS NOT NULL
        GROUP BY
            "ParticipantBarcode", "symbol"
    )
),
table2 AS (
    SELECT
        "symbol",
        "data" AS "rnkdata",
        "ParticipantBarcode"
    FROM (
        SELECT
            "mirna_id" AS "symbol", 
            AVG("reads_per_million_miRNA_mapped") AS "data",
            "case_barcode" AS "ParticipantBarcode"
        FROM "TCGA_HG38_DATA_V0"."TCGA_HG38_DATA_V0"."MIRNASEQ_EXPRESSION"
        WHERE "case_barcode" IN (SELECT "case_barcode" FROM cohort)
            AND "mirna_id" IS NOT NULL
            AND "reads_per_million_miRNA_mapped" IS NOT NULL
        GROUP BY
            "ParticipantBarcode", "symbol"
    )
),
summ_table AS (
    SELECT 
        n1."symbol" AS "symbol1",
        n2."symbol" AS "symbol2",
        COUNT(n1."ParticipantBarcode") AS "n",
        CORR(n1."rnkdata", n2."rnkdata") AS "correlation"
    FROM
        table1 AS n1
    INNER JOIN
        table2 AS n2
    ON
        n1."ParticipantBarcode" = n2."ParticipantBarcode"
    GROUP BY
        "symbol1", "symbol2"
)

SELECT 
    "symbol1", 
    "symbol2", 
    ABS("correlation") * SQRT(( "n" - 2 ) / (1 - "correlation" * "correlation")) AS "t"
FROM 
    summ_table
WHERE 
    "n" > 25 
    AND ABS("correlation") >= 0.3 
    AND ABS("correlation") < 1.0;
