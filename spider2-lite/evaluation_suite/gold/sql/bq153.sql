WITH
table1 AS (
SELECT  symbol, data, ParticipantBarcode
FROM ( 
   SELECT 
         Symbol AS symbol, AVG( LOG10( normalized_count + 1 )) AS data, ParticipantBarcode
   FROM  `spider2-public-data.pancancer_atlas_filtered.EBpp_AdjustPANCAN_IlluminaHiSeq_RNASeqV2_genExp_filtered` 
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
   FROM `spider2-public-data.pancancer_atlas_filtered.clinical_PANCAN_patient_with_followup_filtered`
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
) 

SELECT 
    data2 AS Histology_Type, 
    AVG(data1) AS Average_Log_Expression
FROM 
    table_data
GROUP BY 
    data2;