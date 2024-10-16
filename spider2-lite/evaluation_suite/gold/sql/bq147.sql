WITH rna as (
    SELECT
       case_barcode,
       sample_barcode,
       aliquot_barcode,
       Ensembl_gene_id_v,
       gene_name,
       unstranded,
       fpkm_uq_unstranded,
       sample_type_name,
    FROM `spider2-public-data.TCGA_versioned.RNAseq_hg38_gdc_r35`
    WHERE gene_type = 'protein_coding'
    AND project_short_name = 'TCGA-BRCA'
),
cases as (
  SELECT case_barcode, agg FROM
      (SELECT
        case_barcode,
        array_agg(distinct sample_type_name) agg
      FROM rna
      GROUP BY case_barcode)
  WHERE array_length(agg) > 1
  AND ("Solid Tissue Normal" in UNNEST(agg))
  )
SELECT * FROM cases 