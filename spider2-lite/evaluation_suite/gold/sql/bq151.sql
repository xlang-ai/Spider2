WITH
barcodes AS (
   SELECT bcr_patient_barcode AS ParticipantBarcode
   FROM isb-cgc-bq.pancancer_atlas.Filtered_clinical_PANCAN_patient_with_followup
   WHERE acronym = 'PAAD'
),
table1 AS (
SELECT
   t1.ParticipantBarcode,
   IF(t2.ParticipantBarcode IS NULL, 'NO', 'YES') AS data
FROM
   barcodes AS t1
LEFT JOIN
   (
   SELECT
      ParticipantBarcode AS ParticipantBarcode
   FROM isb-cgc-bq.pancancer_atlas.Filtered_MC3_MAF_V5_one_per_tumor_sample
   WHERE Study = 'PAAD' AND Hugo_Symbol = 'KRAS'
         AND FILTER = 'PASS'
   GROUP BY ParticipantBarcode
   ) AS t2
ON t1.ParticipantBarcode = t2.ParticipantBarcode
),
table2 AS (
SELECT
   t1.ParticipantBarcode,
   IF(t2.ParticipantBarcode IS NULL, 'NO', 'YES') AS data
FROM
   barcodes AS t1
LEFT JOIN
   (
   SELECT
      ParticipantBarcode AS ParticipantBarcode
   FROM isb-cgc-bq.pancancer_atlas.Filtered_MC3_MAF_V5_one_per_tumor_sample
   WHERE Study = 'PAAD' AND Hugo_Symbol = 'TP53'
         AND FILTER = 'PASS'
   GROUP BY ParticipantBarcode
   ) AS t2
ON t1.ParticipantBarcode = t2.ParticipantBarcode
),
summ_table AS (
SELECT
   n1.data AS data1,
   n2.data AS data2,
   COUNT(*) AS Nij
FROM
   table1 AS n1
INNER JOIN
   table2 AS n2
ON
   n1.ParticipantBarcode = n2.ParticipantBarcode
GROUP BY
  data1, data2
),
contingency_table AS (
SELECT
  MAX(IF((data1 = 'YES') AND (data2 = 'YES'), Nij, 0)) AS a,
  MAX(IF((data1 = 'YES') AND (data2 = 'NO'), Nij, 0)) AS b,
  MAX(IF((data1 = 'NO') AND (data2 = 'YES'), Nij, 0)) AS c,
  MAX(IF((data1 = 'NO') AND (data2 = 'NO'), Nij, 0)) AS d,
  (MAX(IF((data1 = 'YES') AND (data2 = 'YES'), Nij, 0)) + MAX(IF((data1 = 'YES') AND (data2 = 'NO'), Nij, 0))) AS row1_total,
  (MAX(IF((data1 = 'NO') AND (data2 = 'YES'), Nij, 0)) + MAX(IF((data1 = 'NO') AND (data2 = 'NO'), Nij, 0))) AS row2_total,
  (MAX(IF((data1 = 'YES') AND (data2 = 'YES'), Nij, 0)) + MAX(IF((data1 = 'NO') AND (data2 = 'YES'), Nij, 0))) AS col1_total,
  (MAX(IF((data1 = 'YES') AND (data2 = 'NO'), Nij, 0)) + MAX(IF((data1 = 'NO') AND (data2 = 'NO'), Nij, 0))) AS col2_total,
  SUM(Nij) AS grand_total
FROM summ_table
)
SELECT
  POWER((a - (row1_total * col1_total) / grand_total), 2) / ((row1_total * col1_total) / grand_total) +
  POWER((b - (row1_total * col2_total) / grand_total), 2) / ((row1_total * col2_total) / grand_total) +
  POWER((c - (row2_total * col1_total) / grand_total), 2) / ((row2_total * col1_total) / grand_total) +
  POWER((d - (row2_total * col2_total) / grand_total), 2) / ((row2_total * col2_total) / grand_total) AS chi_square_statistic
FROM contingency_table
WHERE a IS NOT NULL AND b IS NOT NULL AND c IS NOT NULL AND d IS NOT NULL;
