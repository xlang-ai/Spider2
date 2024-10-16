SELECT
  A.feature_name,
  A.avg_counts_clust41,
  B.avg_counts_clust41,
  A.avg_counts_clust41 - B.avg_counts_clust41 as mean_diff
FROM (
  SELECT
    feature_name,
    AVG(X_value) AS avg_counts_clust41
  FROM
    `spider2-public-data.HTAN.scRNAseq_MSK_SCLC_combined_samples_current`
  WHERE development_stage = '74-year-old human stage' AND Cell_Type = 'epithelial cell' AND clusters = '41' AND sex = 'female'
  GROUP BY
    1) AS A
INNER JOIN (
  SELECT
    feature_name,
    AVG(X_value) AS avg_counts_clust41
  FROM
    `spider2-public-data.HTAN.scRNAseq_MSK_SCLC_combined_samples_current`
  WHERE development_stage = '74-year-old human stage' AND Cell_Type = 'epithelial cell' AND clusters = '41' AND sex = 'male'
  GROUP BY
    1) AS B
ON
  A.feature_name = B.feature_name
GROUP BY 1,2,3
ORDER BY mean_diff DESC
LIMIT 20