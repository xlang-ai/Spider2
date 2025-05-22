/* emergency visits */
/* collapse er claim lines with no days between them into one visit */

SELECT
    t2.encounter_id
    , t2.patient_id
    , t2.encounter_class
    , t2.visit_start_date
    , t2.visit_end_date
FROM (
    SELECT
        min(encounter_id) AS encounter_id
        , patient_id
        , encounter_class
        , visit_start_date
        , max(visit_end_date) AS visit_end_date
    FROM (
        SELECT
            cl1.encounter_id
            , cl1.patient_id
            , cl1.encounter_class
            , cl1.encounter_start_datetime AS visit_start_date
            , cl2.encounter_stop_datetime AS visit_end_date
        FROM {{ ref( 'stg_synthea__encounters') }} AS cl1
        INNER JOIN {{ ref( 'stg_synthea__encounters') }} AS cl2
            ON
                cl1.patient_id = cl2.patient_id
                AND cl1.encounter_start_datetime = cl2.encounter_start_datetime
                AND cl1.encounter_class = cl2.encounter_class
        WHERE cl1.encounter_class IN ('emergency', 'urgent')
    ) AS t1
    GROUP BY patient_id, encounter_class, visit_start_date
) AS t2
