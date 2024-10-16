WITH cohort AS(
    SELECT case_barcode FROM `isb-cgc.TCGA_bioclin_v0.Clinical`
    WHERE project_short_name = "TCGA-BRCA" AND age_at_diagnosis <= 80
        AND pathologic_stage in ('Stage I','Stage II','Stage IIA')
),
table1 AS (
    SELECT
        symbol,
        data AS rnkdata,
        ParticipantBarcode
    FROM (
        SELECT
            gene_name AS symbol, 
            AVG( LOG10( HTSeq__Counts + 1 ) )  AS data,
            case_barcode AS ParticipantBarcode
        FROM `spider2-public-data.TCGA_hg38_data_v0.RNAseq_Gene_Expression`
        WHERE case_barcode IN ( SELECT case_barcode FROM cohort )     # cohort 
                AND gene_name  =  'SNORA31'   # labels 
                AND HTSeq__Counts IS NOT NULL  
        GROUP BY
            ParticipantBarcode, symbol
    )
),
table2 AS (
    SELECT
        symbol,
        data AS rnkdata,
        ParticipantBarcode
    FROM (
    SELECT
        mirna_id AS symbol, 
        AVG( reads_per_million_miRNA_mapped ) AS data,
        case_barcode AS ParticipantBarcode
    FROM `spider2-public-data.TCGA_hg38_data_v0.miRNAseq_Expression`
    WHERE case_barcode IN ( SELECT case_barcode FROM cohort )     # cohort 
            AND mirna_id  IS NOT NULL   # labels 
            AND reads_per_million_miRNA_mapped IS NOT NULL  
    GROUP BY
        ParticipantBarcode, symbol
    )
),
summ_table AS (
    SELECT 
        n1.symbol as symbol1,
        n2.symbol as symbol2,
        COUNT(n1.ParticipantBarcode) as n,
        CORR(n1.rnkdata , n2.rnkdata) as correlation    
    FROM
    table1 AS n1
    INNER JOIN
    table2 AS n2
    ON
    n1.ParticipantBarcode = n2.ParticipantBarcode
    
    GROUP BY
        symbol1, symbol2
)

SELECT symbol1, symbol2, 
        ABS(correlation) * SQRT( (n - 2) / (1 - correlation * correlation)) AS t
FROM summ_table
WHERE n > 25 AND ABS(correlation) >= 0.3 AND ABS(correlation) < 1.0