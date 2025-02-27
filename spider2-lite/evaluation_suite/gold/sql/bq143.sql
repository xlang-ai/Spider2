WITH 
quant AS (
    SELECT 
        meta.sample_submitter_id, 
        meta.sample_type, 
        quant.case_id, 
        quant.aliquot_id, 
        quant.gene_symbol, 
        CAST(quant.protein_abundance_log2ratio AS FLOAT64) AS protein_abundance_log2ratio 
    FROM 
        `isb-cgc-bq.CPTAC.quant_proteome_CPTAC_CCRCC_discovery_study_pdc_current` AS quant
    JOIN 
        `isb-cgc-bq.PDC_metadata.aliquot_to_case_mapping_current` AS meta
        ON quant.case_id = meta.case_id
        AND quant.aliquot_id = meta.aliquot_id
        AND meta.sample_type IN ('Primary Tumor', 'Solid Tissue Normal')
),
gexp AS (
    SELECT DISTINCT 
        meta.sample_submitter_id, 
        meta.sample_type, 
        rnaseq.gene_name, 
        LOG(rnaseq.fpkm_unstranded + 1) AS HTSeq__FPKM   -- Confirm the correct column name here
    FROM 
        `isb-cgc-bq.CPTAC.RNAseq_hg38_gdc_current` AS rnaseq
    JOIN 
        `isb-cgc-bq.PDC_metadata.aliquot_to_case_mapping_current` AS meta
        ON meta.sample_submitter_id = rnaseq.sample_barcode
),
correlation AS (
    SELECT 
        quant.gene_symbol, 
        gexp.sample_type, 
        COUNT(*) AS n, 
        CORR(protein_abundance_log2ratio, HTSeq__FPKM) AS corr  -- Confirm the correct column name here
    FROM 
        quant 
    JOIN 
        gexp 
        ON quant.sample_submitter_id = gexp.sample_submitter_id
        AND gexp.gene_name = quant.gene_symbol
        AND gexp.sample_type = quant.sample_type
    GROUP BY 
        quant.gene_symbol, gexp.sample_type
),
pval AS (
    SELECT  
        gene_symbol, 
        sample_type, 
        n, 
        corr
    FROM 
        correlation
    WHERE 
        ABS(corr) <= 0.5
)
SELECT sample_type, AVG(corr)
FROM pval
GROUP BY sample_type;