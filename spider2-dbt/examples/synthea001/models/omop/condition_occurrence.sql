SELECT
    row_number() OVER (ORDER BY p.person_id) AS condition_occurrence_id
    , p.person_id
    , srctostdvm.target_concept_id AS condition_concept_id
    , c.condition_start_date
    , NULL AS condition_start_datetime
    , c.condition_stop_date AS condition_end_date
    , NULL AS condition_end_datetime
    , 32827 AS condition_type_concept_id
    , cast(NULL AS varchar) AS stop_reason
    , pr.provider_id
    , fv.visit_occurrence_id_new AS visit_occurrence_id
    , fv.visit_occurrence_id_new + 1000000 AS visit_detail_id
    , c.condition_code AS condition_source_value
    , srctosrcvm.source_concept_id AS condition_source_concept_id
    , NULL AS condition_status_source_value
    , 0 AS condition_status_concept_id
FROM {{ ref('stg_synthea__conditions') }} AS c
INNER JOIN {{ ref ('int__source_to_standard_vocab_map') }} AS srctostdvm
    ON
        c.condition_code = srctostdvm.source_code
        AND srctostdvm.target_domain_id = 'Condition'
        AND srctostdvm.target_vocabulary_id = 'SNOMED'
        AND srctostdvm.source_vocabulary_id = 'SNOMED'
        AND srctostdvm.target_standard_concept = 'S'
        AND srctostdvm.target_invalid_reason IS NULL
INNER JOIN {{ ref ('int__source_to_source_vocab_map') }} AS srctosrcvm
    ON
        c.condition_code = srctosrcvm.source_code
        AND srctosrcvm.source_vocabulary_id = 'SNOMED'
        AND srctosrcvm.source_domain_id = 'Condition'
LEFT JOIN {{ ref ('int__final_visit_ids') }} AS fv
    ON c.encounter_id = fv.encounter_id
LEFT JOIN {{ ref('stg_synthea__encounters') }} AS e
    ON
        c.encounter_id = e.encounter_id
        AND c.patient_id = e.patient_id
LEFT JOIN {{ ref ('provider') }} AS pr
    ON e.provider_id = pr.provider_source_value
INNER JOIN {{ ref ('person') }} AS p
    ON c.patient_id = p.person_source_value
