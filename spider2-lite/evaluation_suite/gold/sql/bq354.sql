WITH skin_condition_ICD_concept_ids AS (
    SELECT
        concept_id,
        CASE concept_code
            WHEN 'L70' THEN 'Acne'
            WHEN 'L20' THEN 'Atopic dermatitis'
            WHEN 'L40' THEN 'Psoriasis'
            ELSE 'Vitiligo'
        END AS skin_condition
    FROM
        `bigquery-public-data.cms_synthetic_patient_data_omop.concept`
    WHERE
        concept_code IN ('L70', 'L20', 'L40', 'L80')
        AND vocabulary_id = 'ICD10CM'
),
standard_concept_ids AS (
    SELECT
        concept_id
    FROM
        `bigquery-public-data.cms_synthetic_patient_data_omop.concept`
    WHERE
        standard_concept = 'S'
),
skin_condition_standard_concept_ids AS (
    SELECT
        s.skin_condition,
        r.concept_id_2 AS concept_id
    FROM
        skin_condition_ICD_concept_ids s
    JOIN
        `bigquery-public-data.cms_synthetic_patient_data_omop.concept_relationship` r
    ON
        s.concept_id = r.concept_id_1
    JOIN
        standard_concept_ids sc
    ON
        sc.concept_id = r.concept_id_2
    WHERE
        r.relationship_id = 'Maps to'
),
all_skin_concept_ids AS (
    SELECT DISTINCT
        skin_condition,
        concept_id
    FROM
        skin_condition_standard_concept_ids
),
descendant_concept_ids AS (
    SELECT
        a.skin_condition,
        ca.descendant_concept_id AS concept_id
    FROM
        all_skin_concept_ids a
    JOIN
        `bigquery-public-data.cms_synthetic_patient_data_omop.concept_ancestor` ca
    ON
        a.concept_id = ca.ancestor_concept_id
),
participants_with_condition AS (
    SELECT
        d.skin_condition,
        COUNT(DISTINCT co.person_id) AS nb_of_participants_with_skin_condition
    FROM
        `bigquery-public-data.cms_synthetic_patient_data_omop.condition_occurrence` co
    JOIN
        descendant_concept_ids d
    ON
        co.condition_concept_id = d.concept_id
    GROUP BY
        d.skin_condition
),
total_participants AS (
    SELECT
        COUNT(DISTINCT person_id) AS nb_of_participants
    FROM
        `bigquery-public-data.cms_synthetic_patient_data_omop.person`
)
SELECT
    p.skin_condition,
    100 * p.nb_of_participants_with_skin_condition / t.nb_of_participants AS percentage_of_participants
FROM
    participants_with_condition p,
    total_participants t