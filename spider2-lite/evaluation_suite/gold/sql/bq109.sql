WITH coloc_stats AS (
  SELECT
    coloc.coloc_log2_h4_h3,
    coloc.right_study AS qtl_source
  FROM
    `open-targets-genetics.genetics.variant_disease_coloc` AS coloc
  JOIN
    `open-targets-genetics.genetics.studies` AS studies
  ON
    coloc.left_study = studies.study_id
  WHERE
    coloc.right_gene_id = "ENSG00000169174"
    AND coloc.coloc_h4 > 0.8
    AND coloc.coloc_h3 < 0.02
    AND studies.trait_reported LIKE "%lesterol levels%"
    AND coloc.right_bio_feature = 'IPSC'
    AND CONCAT(coloc.left_chrom, '_', coloc.left_pos, '_', coloc.left_ref, '_', coloc.left_alt) = '1_55029009_C_T'
),
max_value AS (
  SELECT
    MAX(coloc_log2_h4_h3) AS max_log2_h4_h3
  FROM
    coloc_stats
)

SELECT
  AVG(coloc_log2_h4_h3) AS average,
  VAR_SAMP(coloc_log2_h4_h3) AS variance,
  MAX(coloc_log2_h4_h3) - MIN(coloc_log2_h4_h3) AS max_min_difference,
  (SELECT qtl_source FROM coloc_stats WHERE coloc_log2_h4_h3 = (SELECT max_log2_h4_h3 FROM max_value)) AS qtl_source_of_max
FROM
  coloc_stats;