WITH s1 AS (
  SELECT
    sample_barcode_tumor AS sample_barcode
  FROM
    `isb-cgc.TCGA_hg38_data_v0.Somatic_Mutation_DR10`
  WHERE
    project_short_name = 'TCGA-UCEC'
  GROUP BY
    1
),

sampleGroup AS (
  SELECT
    sample_barcode
  FROM
    `isb-cgc.TCGA_hg38_data_v0.RNAseq_Gene_Expression`
  WHERE
    project_short_name = 'TCGA-UCEC'
    AND sample_barcode IN (SELECT sample_barcode FROM s1)
  GROUP BY
    1
),

grp1 AS (
  SELECT
    sample_barcode_tumor AS sample_barcode
  FROM
    `isb-cgc.TCGA_hg38_data_v0.Somatic_Mutation_DR10`
  WHERE
    Hugo_Symbol = 'PARP1'
    AND One_Consequence <> 'synonymous_variant'
    AND sample_barcode_tumor IN (SELECT sample_barcode FROM sampleGroup)
  GROUP BY
    sample_barcode
),

grp2 AS (
  SELECT
    sample_barcode
  FROM
    sampleGroup
  WHERE
    sample_barcode NOT IN (SELECT sample_barcode FROM grp1)
),

summaryGrp1 AS (
  SELECT
    gene_name AS symbol,
    AVG(LOG10(HTSeq__FPKM_UQ + 1)) AS genemean,
    VAR_SAMP(LOG10(HTSeq__FPKM_UQ + 1)) AS genevar,
    COUNT(sample_barcode) AS genen
  FROM
    `isb-cgc.TCGA_hg38_data_v0.RNAseq_Gene_Expression`
  WHERE
    sample_barcode IN (SELECT sample_barcode FROM grp1)
    AND gene_name IN (SELECT Symbol FROM `isb-cgc.QotM.WikiPathways_20170425_Annotated`)
  GROUP BY
    gene_name
),

summaryGrp2 AS (
  SELECT
    gene_name AS symbol,
    AVG(LOG10(HTSeq__FPKM_UQ + 1)) AS genemean,
    VAR_SAMP(LOG10(HTSeq__FPKM_UQ + 1)) AS genevar,
    COUNT(sample_barcode) AS genen
  FROM
    `isb-cgc.TCGA_hg38_data_v0.RNAseq_Gene_Expression`
  WHERE
    sample_barcode IN (SELECT sample_barcode FROM grp2)
    AND gene_name IN (SELECT Symbol FROM `isb-cgc.QotM.WikiPathways_20170425_Annotated`)
  GROUP BY
    gene_name
),

tStatsPerGene AS (
  SELECT
    grp1.symbol AS symbol,
    grp1.genen AS grp1_n,
    grp2.genen AS grp2_n,
    grp1.genemean AS grp1_mean,
    grp2.genemean AS grp2_mean,
    grp1.genemean - grp2.genemean AS meandiff,
    IF (
      (grp1.genevar > 0 AND grp2.genevar > 0 AND grp1.genen > 0 AND grp2.genen > 0),
      (grp1.genemean - grp2.genemean) / SQRT((POW(grp1.genevar, 2) / grp1.genen) + (POW(grp2.genevar, 2) / grp2.genen)),
      0.0
    ) AS tstat
  FROM
    summaryGrp1 AS grp1
  JOIN
    summaryGrp2 AS grp2 ON grp1.symbol = grp2.symbol
  GROUP BY
    grp1.symbol, grp1.genemean, grp2.genemean, grp1.genevar, grp2.genevar, grp1.genen, grp2.genen
),

geneSetTable AS (
  SELECT
    gs.pathway,
    gs.wikiID,
    gs.Symbol,
    st.grp1_n,
    st.grp2_n,
    st.grp1_mean,
    st.grp2_mean,
    st.meandiff,
    st.tstat
  FROM
    `isb-cgc.QotM.WikiPathways_20170425_Annotated` AS gs
  JOIN
    tStatsPerGene AS st ON st.symbol = gs.symbol
  GROUP BY
    gs.pathway, gs.wikiID, gs.Symbol, st.grp1_n, st.grp2_n, st.grp1_mean, st.grp2_mean, st.meandiff, st.tstat
),

geneSetScores AS (
  SELECT
    pathway,
    wikiID,
    COUNT(symbol) AS n_genes,
    AVG(ABS(meandiff)) AS avgAbsDiff,
    (SQRT(COUNT(symbol)) / COUNT(symbol)) * SUM(tstat) AS score
  FROM
    geneSetTable
  GROUP BY
    pathway, wikiID
)

SELECT
  pathway
FROM
  geneSetScores
ORDER BY
  score DESC
LIMIT 5
