WITH Cdh1MutatedPatients AS (
    SELECT DISTINCT
        "ParticipantBarcode"
    FROM "PANCANCER_ATLAS_1"."PANCANCER_ATLAS_FILTERED"."MC3_MAF_V5_ONE_PER_TUMOR_SAMPLE"
    WHERE
        "Hugo_Symbol" = 'CDH1' AND "FILTER" = 'PASS'
), PatientData AS (
    SELECT
        T1."histological_type",
        CASE
            WHEN T2."ParticipantBarcode" IS NOT NULL THEN 'mutated'
            ELSE 'not_mutated'
        END AS mutation_status
    FROM "PANCANCER_ATLAS_1"."PANCANCER_ATLAS_FILTERED"."CLINICAL_PANCAN_PATIENT_WITH_FOLLOWUP_FILTERED" AS T1
    LEFT JOIN Cdh1MutatedPatients AS T2
        ON T1."bcr_patient_barcode" = T2."ParticipantBarcode"
    WHERE
        T1."acronym" = 'BRCA'
        AND T1."histological_type" IS NOT NULL
), InitialContingency AS (
    SELECT
        "histological_type",
        mutation_status,
        COUNT(*) AS observed
    FROM PatientData
    GROUP BY
        "histological_type",
        mutation_status
), FilteredContingency AS (
    SELECT
        "histological_type",
        mutation_status,
        observed
    FROM InitialContingency
    WHERE
        "histological_type" IN (
            SELECT "histological_type"
            FROM InitialContingency
            GROUP BY "histological_type"
            HAVING SUM(observed) > 10
        )
        AND mutation_status IN (
            SELECT mutation_status
            FROM InitialContingency
            GROUP BY mutation_status
            HAVING SUM(observed) > 10
        )
), ChiSquareInput AS (
    SELECT
        "histological_type",
        mutation_status,
        observed,
        SUM(observed) OVER (PARTITION BY "histological_type") AS row_total,
        SUM(observed) OVER (PARTITION BY mutation_status) AS col_total,
        SUM(observed) OVER () AS grand_total
    FROM FilteredContingency
)
SELECT
    SUM(POWER(observed - (row_total * col_total / grand_total), 2) / (row_total * col_total / grand_total))
FROM ChiSquareInput;