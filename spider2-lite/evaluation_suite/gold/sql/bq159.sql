WITH
table1 AS (
SELECT
   symbol,
   avgdata AS data,
   ParticipantBarcode
FROM (
   SELECT
      'histological_type' AS symbol, 
      histological_type AS avgdata,
      bcr_patient_barcode AS ParticipantBarcode
   FROM `spider2-public-data.pancancer_atlas_filtered.clinical_PANCAN_patient_with_followup_filtered`
   WHERE acronym = 'BRCA'   AND histological_type IS NOT NULL      
   )
)
,table2 AS (
SELECT
   symbol,
   ParticipantBarcode
FROM (
   SELECT
      Hugo_Symbol AS symbol, 
      ParticipantBarcode AS ParticipantBarcode
   FROM `spider2-public-data.pancancer_atlas_filtered.MC3_MAF_V5_one_per_tumor_sample`
   WHERE Study = 'BRCA' AND Hugo_Symbol = 'CDH1'
         AND FILTER = 'PASS'  
   GROUP BY
      ParticipantBarcode, symbol
   )
)
,summ_table AS (
SELECT 
   n1.data as data1,
   IF( n2.ParticipantBarcode is null, 'NO', 'YES') as data2,
   COUNT(*) as Nij
FROM
   table1 AS n1
LEFT JOIN
   table2 AS n2
ON
   n1.ParticipantBarcode = n2.ParticipantBarcode
GROUP BY
  data1, data2
) 
,expected_table AS (
SELECT data1, data2
FROM (     
    SELECT data1, SUM(Nij) as Ni   
    FROM summ_table
    GROUP BY data1 ) 
CROSS JOIN ( 
    SELECT data2, SUM(Nij) as Nj
    FROM summ_table
    GROUP BY data2 )
    
WHERE Ni > 10 AND Nj > 10
)
,contingency_table AS (
SELECT
   T1.data1,
   T1.data2,
   IF( Nij IS NULL, 0, Nij) as Nij,
   (SUM(Nij) OVER (PARTITION BY T1.data1))*(SUM(Nij) OVER (PARTITION BY T1.data2))/ SUM(Nij) OVER () AS  E_nij
    
FROM
   expected_table AS T1
LEFT JOIN
   summ_table AS T2
ON 
  T1.data1 = T2.data1 AND T1.data2 = T2.data2
)

   SELECT
     SUM( (Nij - E_nij)*(Nij - E_nij) / E_nij ) as Chi2    
   FROM contingency_table