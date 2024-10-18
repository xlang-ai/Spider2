WITH
barcodes AS (
   SELECT Tumor_SampleBarcode AS SampleBarcode   
   FROM `spider2-public-data.pancancer_atlas_filtered.MC3_MAF_V5_one_per_tumor_sample`
   WHERE Study = 'LGG'       
)
,table1 AS (
SELECT Symbol, data, ParticipantBarcode
FROM ( 
   SELECT 
         Symbol AS symbol, AVG( LOG10( normalized_count + 1 )) AS data, ParticipantBarcode
   FROM  `spider2-public-data.pancancer_atlas_filtered.EBpp_AdjustPANCAN_IlluminaHiSeq_RNASeqV2_genExp_filtered` 
   WHERE Study = 'LGG' AND Symbol ='DRG2' AND normalized_count IS NOT NULL
         AND SampleBarcode  IN (SELECT * FROM barcodes)
         
   GROUP BY 
         ParticipantBarcode, symbol
   )
)
,table2 AS (
SELECT   
   ParticipantBarcode 
FROM
   (
   SELECT
      ParticipantBarcode AS ParticipantBarcode
   FROM `spider2-public-data.pancancer_atlas_filtered.MC3_MAF_V5_one_per_tumor_sample`
   WHERE Study = 'LGG' AND Hugo_Symbol = 'TP53'
         AND FILTER = 'PASS'  
   GROUP BY ParticipantBarcode
   ) 
)
,summ_table AS (
SELECT 
   Symbol,
   COUNT( n1.ParticipantBarcode) as Ny,
   SUM( n1.data )  as Sy,
   SUM( n1.data * n1.data ) as Qy
   
FROM
   table1 AS n1
INNER JOIN
   table2 AS n2
ON
   n1.ParticipantBarcode = n2.ParticipantBarcode
GROUP BY Symbol
)

SELECT 
    Ny, Nn,
    avg_y, avg_n,
    ABS(avg_y - avg_n)/ SQRT( var_y /Ny + var_n/Nn )  as tscore
FROM (
SELECT Ny, 
       Sy / Ny as avg_y,
       ( Qy - Sy*Sy/Ny )/(Ny - 1) as var_y, 
       Nt - Ny as Nn,
       (St - Sy)/(Nt - Ny) as avg_n,
       (Qt - Qy - (St-Sy)*(St-Sy)/(Nt - Ny) )/(Nt - Ny -1 ) as var_n
FROM  summ_table as n1
LEFT JOIN ( SELECT Symbol, COUNT( ParticipantBarcode ) as Nt, SUM( data ) as St, SUM( data*data ) as Qt
            FROM table1 GROUP BY Symbol
           ) as n2
ON n1.Symbol = n2.Symbol      
)
WHERE
   Ny > 10 AND Nn > 10 AND var_y > 0 and var_n > 0