WITH
    table1 AS (
        SELECT 
            "Symbol" AS "symbol", 
            AVG(LOG(10, "normalized_count" + 1)) AS "data", 
            "ParticipantBarcode"
        FROM 
            PANCANCER_ATLAS_1.PANCANCER_ATLAS_FILTERED.EBPP_ADJUSTPANCAN_ILLUMINAHISEQ_RNASEQV2_GENEXP_FILTERED
        WHERE 
            "Study" = 'LGG' 
            AND "Symbol" = 'IGF2' 
            AND "normalized_count" IS NOT NULL
        GROUP BY 
            "ParticipantBarcode", "symbol"
    ),
    table2 AS (
        SELECT
            "symbol",
            "avgdata" AS "data",
            "ParticipantBarcode"
        FROM (
            SELECT
                'icd_o_3_histology' AS "symbol", 
                "icd_o_3_histology" AS "avgdata",
                "bcr_patient_barcode" AS "ParticipantBarcode"
            FROM 
                PANCANCER_ATLAS_1.PANCANCER_ATLAS_FILTERED.CLINICAL_PANCAN_PATIENT_WITH_FOLLOWUP_FILTERED
            WHERE 
                "acronym" = 'LGG' 
                AND "icd_o_3_histology" IS NOT NULL  
                AND NOT REGEXP_LIKE("icd_o_3_histology", '^(\\[.*\\]$)')
        )
    ),
    table_data AS (
        SELECT 
            n1."data" AS "data1",
            n2."data" AS "data2",
            n1."ParticipantBarcode"
        FROM 
            table1 AS n1
        INNER JOIN 
            table2 AS n2
        ON 
            n1."ParticipantBarcode" = n2."ParticipantBarcode"
    ) 

SELECT 
    "data2" AS "Histology_Type", 
    AVG("data1") AS "Average_Log_Expression"
FROM 
    table_data
GROUP BY 
    "data2";
