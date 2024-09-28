WITH select_on_annotations AS (
    SELECT
        case_barcode,
        category AS categoryName,
        classification AS classificationName
    FROM
        `isb-cgc.TCGA_bioclin_v0.Annotations`
    WHERE
        entity_type = "Patient"
        AND ( category = "History of unacceptable prior treatment related to a prior/other malignancy"
            OR classification = "Redaction" )
    GROUP BY
        case_barcode,
        categoryName,
        classificationName
),
select_on_clinical AS (
    SELECT
        case_barcode,
        vital_status,
        days_to_last_known_alive,
        ethnicity,
        histological_type,
        menopause_status,
        race
    FROM
        `isb-cgc.TCGA_bioclin_v0.Clinical`
    WHERE
        ( disease_code = "BRCA"
        AND age_at_diagnosis <= 30
        AND gender = "FEMALE" )
),
-- Combine the cohort with the metadata tables to create a list of GDC urls
cohort AS (
    SELECT
        case_barcode
    FROM (
        SELECT
            a.categoryName,
            a.classificationName,
            c.case_barcode
        FROM
            select_on_annotations AS a
        FULL JOIN
            select_on_clinical AS c
        ON
            a.case_barcode = c.case_barcode
        WHERE
            a.case_barcode IS NOT NULL
            OR c.case_barcode IS NOT NULL
        ORDER BY
            a.classificationName,
            a.categoryName,
            c.case_barcode )
    WHERE
        categoryName IS NULL
        AND classificationName IS NULL
        AND case_barcode IS NOT NULL
    ORDER BY
        case_barcode
),
gdc AS (
    SELECT a.case_barcode, b.case_gdc_id
    FROM cohort AS a
    INNER JOIN `isb-cgc.GDC_metadata.rel14_caseData` AS b -- GDC archive release 14
    ON a.case_barcode = b.case_barcode
),
curr AS (
    SELECT c.case_barcode, c.case_gdc_id, d.file_gdc_id
    FROM gdc as c
    INNER JOIN `isb-cgc.GDC_metadata.rel14_fileData_current` AS d -- GDC archive release 14
    ON c.case_gdc_id = d.case_gdc_id
),
url AS ( 
    SELECT e.case_barcode, e.case_gdc_id, e.file_gdc_id, f.file_gdc_url
    FROM curr AS e
    INNER JOIN `isb-cgc.GDC_metadata.rel14_GDCfileID_to_GCSurl_NEW` AS f -- GDC archive release 14
    ON e.file_gdc_id = f.file_gdc_id
)
SELECT case_barcode, file_gdc_url FROM url ORDER BY case_barcode;