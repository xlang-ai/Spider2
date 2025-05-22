SELECT
    av.visit_occurrence_id
    , p.person_id
    , CASE lower(av.encounter_class)
        WHEN 'ambulatory' THEN 9202
        WHEN 'emergency' THEN 9203
        WHEN 'inpatient' THEN 9201
        WHEN 'wellness' THEN 9202
        WHEN 'urgentcare' THEN 9203
        WHEN 'outpatient' THEN 9202
        ELSE 0
    END AS visit_concept_id
    , {{ dbt.safe_cast("av.visit_start_date", api.Column.translate_type("date")) }} AS visit_start_date
    , av.visit_start_date AS visit_start_datetime
    , {{ dbt.safe_cast("av.visit_end_date", api.Column.translate_type("date")) }} AS visit_end_date
    , av.visit_end_date AS visit_end_datetime
    , 32827 AS visit_type_concept_id
    , pr.provider_id
    , null AS care_site_id
    , av.encounter_id AS visit_source_value
    , 0 AS visit_source_concept_id
    , 0 AS admitted_from_concept_id
    , null AS admitted_from_source_value
    , 0 AS discharged_to_concept_id
    , null AS discharged_to_source_value
    , lag(av.visit_occurrence_id)
        OVER (
            PARTITION BY p.person_id
            ORDER BY av.visit_start_date
        )
    AS preceding_visit_occurrence_id
FROM {{ ref( 'int__all_visits') }} AS av
INNER JOIN {{ ref( 'person') }} AS p
    ON av.patient_id = p.person_source_value
INNER JOIN {{ ref('stg_synthea__encounters') }} AS e
    ON
        av.encounter_id = e.encounter_id
        AND av.patient_id = e.patient_id
INNER JOIN {{ ref( 'provider') }} AS pr
    ON e.provider_id = pr.provider_source_value
WHERE av.visit_occurrence_id IN (
    SELECT DISTINCT visit_occurrence_id_new
    FROM {{ ref( 'int__final_visit_ids') }}
)
