WITH quinapril_concept AS (
    SELECT concept_id
    FROM `bigquery-public-data.cms_synthetic_patient_data_omop.concept`
    WHERE concept_code = "35208" AND vocabulary_id = "RxNorm"
),
quinapril_related_medications AS (
    SELECT DISTINCT descendant_concept_id AS concept_id
    FROM `bigquery-public-data.cms_synthetic_patient_data_omop.concept_ancestor`
    WHERE ancestor_concept_id IN (SELECT concept_id FROM quinapril_concept)
),
participants_with_quinapril AS (
    SELECT COUNT(DISTINCT person_id) AS count
    FROM `bigquery-public-data.cms_synthetic_patient_data_omop.drug_exposure`
    WHERE drug_concept_id IN (SELECT concept_id FROM quinapril_related_medications)
),
total_participants AS (
    SELECT COUNT(DISTINCT person_id) AS count
    FROM `bigquery-public-data.cms_synthetic_patient_data_omop.person`
)
SELECT
    100 - (100 * participants_with_quinapril.count / total_participants.count) AS without_quinapril
FROM
    participants_with_quinapril, total_participants