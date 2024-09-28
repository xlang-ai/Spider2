WITH
table1 AS (
SELECT  symbol, data, ParticipantBarcode
FROM ( 
   SELECT 
         Symbol AS symbol, AVG( LOG10( normalized_count + 1 )) AS data, ParticipantBarcode
   FROM  `pancancer-atlas.Filtered.EBpp_AdjustPANCAN_IlluminaHiSeq_RNASeqV2_genExp_filtered` 
   WHERE Study = 'LGG' AND Symbol ='IGF2' AND normalized_count IS NOT NULL
   GROUP BY 
         ParticipantBarcode, symbol
   )
)
,table2 AS (
SELECT
   symbol,
   avgdata AS data,
   ParticipantBarcode
FROM (
   SELECT
      'icd_o_3_histology' AS symbol, 
      icd_o_3_histology AS avgdata,
      bcr_patient_barcode AS ParticipantBarcode
   FROM `pancancer-atlas.Filtered.clinical_PANCAN_patient_with_followup_filtered`
   WHERE acronym = 'LGG' AND icd_o_3_histology IS NOT NULL  
         AND NOT REGEXP_CONTAINS(icd_o_3_histology,r"^(\[.*\]$)")     
   )
)
,table_data AS (
SELECT 
   n1.data as data1,
   n2.data as data2,
   n1.ParticipantBarcode
FROM
   table1 AS n1
INNER JOIN
   table2 AS n2
ON
   n1.ParticipantBarcode = n2.ParticipantBarcode
),
summ_table  AS (
SELECT 
   COUNT( ParticipantBarcode) AS ni,
   SUM( rnkdata ) AS Si,
   SUM( rnkdata * rnkdata ) AS Qi,
   data2
FROM (    
   SELECT 
      (RANK() OVER (ORDER BY data1 ASC)) + (COUNT(*) OVER ( PARTITION BY CAST(data1 as STRING)) - 1)/2.0 AS rnkdata,
      data2, ParticipantBarcode
   FROM
      table_data 
   WHERE data2 IN ( SELECT data2 from table_data GROUP BY data2 HAVING count(data2)>26 )   
)
GROUP BY
   data2
)

SELECT 
    Ngroups,
    N as Nsamples,        
    (N-1)*( sumSi2overni - (sumSi *sumSi)/N ) / (  sumQi  - (sumSi *sumSi)/N )    AS  Hscore 
FROM (
  SELECT 
      SUM( ni ) As N, 
      SUM( Si ) AS sumSi,
      SUM( Qi ) AS sumQi,
      SUM( Si * Si  / ni ) AS sumSi2overni,
      COUNT ( data2 ) AS Ngroups    
  FROM  summ_table
  )
WHERE 
   Ngroups > 1
ORDER BY Hscore DESC