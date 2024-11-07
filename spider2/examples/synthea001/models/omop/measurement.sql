WITH snomed_measurements AS (
    SELECT
        p.person_id
        , srctostdvm.target_concept_id AS measurement_concept_id
        , {{ dbt.safe_cast("pr.procedure_start_datetime", api.Column.translate_type("date")) }} AS measurement_date
        , pr.procedure_start_datetime AS measurement_datetime
        , {{ dbt.safe_cast("pr.procedure_start_datetime", api.Column.translate_type("time")) }} AS measurement_time
        , 32827 AS measurement_type_concept_id
        , 0 AS operator_concept_id
        , cast(null AS float) AS value_as_number
        , 0 AS value_as_concept_id
        , 0 AS unit_concept_id
        , cast(null AS float) AS range_low
        , cast(null AS float) AS range_high
        , prv.provider_id
        , fv.visit_occurrence_id_new AS visit_occurrence_id
        , fv.visit_occurrence_id_new + 1000000 AS visit_detail_id
        , pr.procedure_code AS measurement_source_value
        , srctosrcvm.source_concept_id AS measurement_source_concept_id
        , cast(null AS varchar) AS unit_source_value
        , cast(null AS varchar) AS value_source_value
        , cast(null AS int) AS unit_source_concept_id
        , cast(null AS bigint) AS measurement_event_id
        , cast(null AS int) AS meas_event_field_concept_id
    FROM {{ ref ('stg_synthea__procedures') }} AS pr
    INNER JOIN {{ ref ('int__source_to_standard_vocab_map') }} AS srctostdvm
        ON
            pr.procedure_code = srctostdvm.source_code
            AND srctostdvm.target_domain_id = 'Measurement'
            AND srctostdvm.source_vocabulary_id = 'SNOMED'
            AND srctostdvm.target_standard_concept = 'S'
            AND srctostdvm.target_invalid_reason IS null
    INNER JOIN {{ ref ('int__source_to_source_vocab_map') }} AS srctosrcvm
        ON
            pr.procedure_code = srctosrcvm.source_code
            AND srctosrcvm.source_vocabulary_id = 'SNOMED'
    LEFT JOIN {{ ref ('int__final_visit_ids') }} AS fv
        ON pr.encounter_id = fv.encounter_id
    LEFT JOIN {{ ref ('stg_synthea__encounters') }} AS e
        ON
            pr.encounter_id = e.encounter_id
            AND pr.patient_id = e.patient_id
    LEFT JOIN {{ ref ('provider') }} AS prv
        ON e.provider_id = prv.provider_source_value
    INNER JOIN {{ ref ('person') }} AS p
        ON pr.patient_id = p.person_source_value
)

, loinc_measurements AS (

    SELECT
        p.person_id
        , srctostdvm.target_concept_id AS measurement_concept_id
        , {{ dbt.safe_cast("o.observation_datetime", api.Column.translate_type("date")) }} AS measurement_date
        , o.observation_datetime AS measurement_datetime
        , {{ dbt.safe_cast("o.observation_datetime", api.Column.translate_type("time")) }} AS measurement_time
        , 32827 AS measurement_type_concept_id
        , 0 AS operator_concept_id
        , CASE
            WHEN o.observation_value ~ '^[-+]?[0-9]+\.?[0-9]*$'
                THEN cast(o.observation_value AS float)
            ELSE cast(null AS float)
        END AS value_as_number
        , coalesce(srcmap2.target_concept_id, 0) AS value_as_concept_id
        , coalesce(srcmap1.target_concept_id, 0) AS unit_concept_id
        , cast(null AS float) AS range_low
        , cast(null AS float) AS range_high
        , pr.provider_id
        , fv.visit_occurrence_id_new AS visit_occurrence_id
        , fv.visit_occurrence_id_new + 1000000 AS visit_detail_id
        , o.observation_code AS measurement_source_value
        , coalesce(
            srctosrcvm.source_concept_id, 0
        ) AS measurement_source_concept_id
        , o.observation_units AS unit_source_value
        , o.observation_value AS value_source_value
        , cast(null AS int) AS unit_source_concept_id
        , cast(null AS bigint) AS measurement_event_id
        , cast(null AS int) AS meas_event_field_concept_id

    FROM {{ ref ('stg_synthea__observations') }} AS o
    INNER JOIN {{ ref ('int__source_to_standard_vocab_map') }} AS srctostdvm
        ON
            o.observation_code = srctostdvm.source_code
            AND srctostdvm.target_domain_id = 'Measurement'
            AND srctostdvm.source_vocabulary_id = 'LOINC'
            AND srctostdvm.target_standard_concept = 'S'
            AND srctostdvm.target_invalid_reason IS null
    LEFT JOIN {{ ref ('int__source_to_standard_vocab_map') }} AS srcmap1
        ON
            o.observation_units = srcmap1.source_code
            AND srcmap1.target_vocabulary_id = 'UCUM'
            AND srcmap1.source_vocabulary_id = 'UCUM'
            AND srcmap1.target_standard_concept = 'S'
            AND srcmap1.target_invalid_reason IS null
    LEFT JOIN {{ ref ('int__source_to_standard_vocab_map') }} AS srcmap2
        ON
            o.observation_value = srcmap2.source_code
            AND srcmap2.target_domain_id = 'Meas value'
            AND srcmap2.target_standard_concept = 'S'
            AND srcmap2.target_invalid_reason IS null
    LEFT JOIN {{ ref ('int__source_to_source_vocab_map') }} AS srctosrcvm
        ON
            o.observation_code = srctosrcvm.source_code
            AND srctosrcvm.source_vocabulary_id = 'LOINC'
    LEFT JOIN {{ ref ('int__final_visit_ids') }} AS fv
        ON o.encounter_id = fv.encounter_id
    LEFT JOIN {{ ref ('stg_synthea__encounters') }} AS e
        ON
            o.encounter_id = e.encounter_id
            AND o.patient_id = e.patient_id
    LEFT JOIN {{ ref ('provider') }} AS pr
        ON e.provider_id = pr.provider_source_value
    INNER JOIN {{ ref ('person') }} AS p
        ON o.patient_id = p.person_source_value
)

, all_measurements AS (
    SELECT * FROM snomed_measurements
    UNION ALL
    SELECT * FROM loinc_measurements
)

SELECT
    row_number() OVER (ORDER BY am.person_id) AS measurement_id
    , am.*
FROM all_measurements AS am
