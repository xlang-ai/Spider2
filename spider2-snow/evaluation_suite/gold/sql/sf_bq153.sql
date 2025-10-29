WITH PatientAvg AS (
    SELECT
        T1."bcr_patient_barcode",
        T1."icd_o_3_histology",
        AVG(LOG(10, T2."normalized_count" + 1)) AS AvgLogExpression
    FROM "PANCANCER_ATLAS_1"."PANCANCER_ATLAS_FILTERED"."CLINICAL_PANCAN_PATIENT_WITH_FOLLOWUP_FILTERED" AS T1
    JOIN "PANCANCER_ATLAS_1"."PANCANCER_ATLAS_FILTERED"."EBPP_ADJUSTPANCAN_ILLUMINAHISEQ_RNASEQV2_GENEXP_FILTERED" AS T2
        ON T1."bcr_patient_barcode" = T2."ParticipantBarcode"
    WHERE
        T1."acronym" = 'LGG'
        AND T2."Symbol" = 'IGF2'
        AND T1."icd_o_3_histology" IS NOT NULL
        AND NOT (T1."icd_o_3_histology" LIKE '[%' AND T1."icd_o_3_histology" LIKE '%]')
    GROUP BY
        T1."bcr_patient_barcode",
        T1."icd_o_3_histology"
)
SELECT
    "icd_o_3_histology",
    AVG(AvgLogExpression)
FROM PatientAvg
GROUP BY
    "icd_o_3_histology";