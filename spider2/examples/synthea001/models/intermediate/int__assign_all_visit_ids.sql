/*assign visit_occurrence_id to all encounters*/

SELECT
    e.encounter_id
    , e.patient_id AS person_source_value
    , e.encounter_start_datetime AS date_service
    , e.encounter_stop_datetime AS date_service_end
    , e.encounter_class
    , av.encounter_class AS visit_type
    , av.visit_start_date
    , av.visit_end_date
    , av.visit_occurrence_id
    , CASE
        WHEN
            e.encounter_class = 'inpatient' AND av.encounter_class = 'inpatient'
            THEN visit_occurrence_id
        WHEN e.encounter_class IN ('emergency', 'urgent')
            THEN (
                CASE
                    WHEN
                        av.encounter_class = 'inpatient'
                        AND e.encounter_start_datetime > av.visit_start_date
                        THEN visit_occurrence_id
                    WHEN
                        av.encounter_class IN ('emergency', 'urgent')
                        AND e.encounter_start_datetime = av.visit_start_date
                        THEN visit_occurrence_id
                END
            )
        WHEN e.encounter_class IN ('ambulatory', 'wellness', 'outpatient')
            THEN (
                CASE
                    WHEN
                        av.encounter_class = 'inpatient'
                        AND e.encounter_start_datetime >= av.visit_start_date
                        THEN visit_occurrence_id
                    WHEN
                        av.encounter_class IN (
                            'ambulatory', 'wellness', 'outpatient'
                        )
                        THEN visit_occurrence_id
                END
            )
    END AS visit_occurrence_id_new
FROM {{ ref('stg_synthea__encounters') }} AS e
INNER JOIN {{ ref('int__all_visits') }} AS av
    ON
        e.patient_id = av.patient_id
        AND e.encounter_start_datetime >= av.visit_start_date
        AND e.encounter_start_datetime <= av.visit_end_date
