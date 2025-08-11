SELECT
    row_number() OVER (ORDER BY person_id) AS device_exposure_id
    , p.person_id
    , srctostdvm.target_concept_id AS device_concept_id
    , {{ dbt.safe_cast("d.device_start_datetime", api.Column.translate_type("date")) }} AS device_exposure_start_date
    , d.device_start_datetime AS device_exposure_start_datetime
    , {{ dbt.safe_cast("d.device_stop_datetime", api.Column.translate_type("date")) }} AS device_exposure_end_date
    , d.device_stop_datetime AS device_exposure_end_datetime
    , 32827 AS device_type_concept_id
    , d.udi AS unique_device_id
    , cast(null AS varchar) AS production_id
    , cast(null AS int) AS quantity
    , pr.provider_id
    , fv.visit_occurrence_id_new AS visit_occurrence_id
    , fv.visit_occurrence_id_new + 1000000 AS visit_detail_id
    , d.device_code AS device_source_value
    , srctosrcvm.source_concept_id AS device_source_concept_id
    , cast(null AS int) AS unit_concept_id
    , cast(null AS varchar) AS unit_source_value
    , cast(null AS int) AS unit_source_concept_id
FROM {{ ref('stg_synthea__devices') }} AS d
INNER JOIN {{ ref ('int__source_to_standard_vocab_map') }} AS srctostdvm
    ON
        d.device_code = srctostdvm.source_code
        AND srctostdvm.target_domain_id = 'Device'
        AND srctostdvm.target_vocabulary_id = 'SNOMED'
        AND srctostdvm.source_vocabulary_id = 'SNOMED'
        AND srctostdvm.target_standard_concept = 'S'
        AND srctostdvm.target_invalid_reason IS null
INNER JOIN {{ ref ('int__source_to_source_vocab_map') }} AS srctosrcvm
    ON
        d.device_code = srctosrcvm.source_code
        AND srctosrcvm.source_vocabulary_id = 'SNOMED'
LEFT JOIN {{ ref ('int__final_visit_ids') }} AS fv
    ON d.encounter_id = fv.encounter_id
LEFT JOIN {{ ref('stg_synthea__encounters') }} AS e
    ON
        d.encounter_id = e.encounter_id
        AND d.patient_id = e.patient_id
LEFT JOIN {{ ref ('provider') }} AS pr
    ON e.provider_id = pr.provider_source_value
INNER JOIN {{ ref ('person') }} AS p
    ON d.patient_id = p.person_source_value
