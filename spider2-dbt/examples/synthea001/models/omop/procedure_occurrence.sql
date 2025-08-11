SELECT
    row_number() OVER (ORDER BY p.person_id) AS procedure_occurrence_id
    , p.person_id
    , srctostdvm.target_concept_id AS procedure_concept_id
    , {{ dbt.safe_cast("pr.procedure_start_datetime", api.Column.translate_type("date")) }} AS procedure_date
    , pr.procedure_start_datetime AS procedure_datetime
    , {{ dbt.safe_cast("pr.procedure_stop_datetime", api.Column.translate_type("date")) }} AS procedure_end_date
    , pr.procedure_stop_datetime AS procedure_end_datetime
    , 32827 AS procedure_type_concept_id
    , 0 AS modifier_concept_id
    , cast(null AS integer) AS quantity
    , prv.provider_id
    , fv.visit_occurrence_id_new AS visit_occurrence_id
    , fv.visit_occurrence_id_new + 1000000 AS visit_detail_id
    , pr.procedure_code AS procedure_source_value
    , srctosrcvm.source_concept_id AS procedure_source_concept_id
    , null AS modifier_source_value
FROM {{ ref( 'stg_synthea__procedures') }} AS pr
INNER JOIN {{ ref( 'int__source_to_standard_vocab_map') }} AS srctostdvm
    ON
        pr.procedure_code = srctostdvm.source_code
        AND srctostdvm.target_domain_id = 'Procedure'
        AND srctostdvm.target_vocabulary_id = 'SNOMED'
        AND srctostdvm.source_vocabulary_id = 'SNOMED'
        AND srctostdvm.target_standard_concept = 'S'
        AND srctostdvm.target_invalid_reason IS null
INNER JOIN {{ ref( 'int__source_to_source_vocab_map') }} AS srctosrcvm
    ON
        pr.procedure_code = srctosrcvm.source_code
        AND srctosrcvm.source_vocabulary_id = 'SNOMED'
LEFT JOIN {{ ref( 'int__final_visit_ids') }} AS fv
    ON pr.encounter_id = fv.encounter_id
LEFT JOIN {{ ref( 'stg_synthea__encounters') }} AS e
    ON
        pr.encounter_id = e.encounter_id
        AND pr.patient_id = e.patient_id
LEFT JOIN {{ ref( 'provider') }} AS prv
    ON e.provider_id = prv.provider_source_value
INNER JOIN {{ ref( 'person') }} AS p
    ON pr.patient_id = p.person_source_value
