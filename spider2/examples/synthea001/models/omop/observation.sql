WITH all_observations AS (
    SELECT * FROM {{ ref('int__observation_allergies') }}
    UNION ALL
    SELECT * FROM {{ ref('int__observation_conditions') }}
    UNION ALL
    SELECT * FROM {{ ref('int__observation_observations') }}
)

SELECT
    row_number() OVER (ORDER BY person_id) AS observation_id
    , p.person_id
    , observation_concept_id
    , {{ dbt.safe_cast("observation_date", api.Column.translate_type("date")) }} AS observation_date
    , observation_datetime
    , observation_type_concept_id
    , cast(null AS float) AS value_as_number
    , cast(null AS varchar) AS value_as_string
    , 0 AS value_as_concept_id
    , 0 AS qualifier_concept_id
    , 0 AS unit_concept_id
    , epr.provider_id
    , fv.visit_occurrence_id_new AS visit_occurrence_id
    , fv.visit_occurrence_id_new + 1000000 AS visit_detail_id
    , observation_source_value
    , observation_source_concept_id
    , cast(null AS varchar) AS unit_source_value
    , cast(null AS varchar) AS qualifier_source_value
    , cast(null AS varchar) AS value_source_value
    , cast(null AS bigint) AS observation_event_id
    , cast(null AS int) AS obs_event_field_concept_id
FROM all_observations AS ao
LEFT JOIN {{ ref ('int__final_visit_ids') }} AS fv
    ON ao.encounter_id = fv.encounter_id
LEFT JOIN {{ ref ('int__encounter_provider') }} AS epr
    ON
        ao.encounter_id = epr.encounter_id
        AND ao.patient_id = epr.patient_id
INNER JOIN {{ ref ('person') }} AS p
    ON ao.patient_id = p.person_source_value
