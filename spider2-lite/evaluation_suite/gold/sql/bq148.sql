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
  WHERE "Solid Tissue Normal" in UNNEST(agg)
  ),
mean_expr as (
  SELECT * FROM (
    SELECT
      rna.Ensembl_gene_id_v,
      VARIANCE(rna.fpkm_uq_unstranded) var_fpkm
    FROM rna
    JOIN cases ON rna.case_barcode = cases.case_barcode
    WHERE rna.sample_type_name = 'Solid Tissue Normal'
    GROUP BY rna.Ensembl_gene_id_v)
  ORDER BY var_fpkm DESC
  )

SELECT * FROM mean_expr LIMIT 5