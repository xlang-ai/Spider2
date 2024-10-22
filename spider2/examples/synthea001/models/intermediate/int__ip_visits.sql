/* inpatient visits */
/* collapse ip claim lines with <=1 day between them into one visit */

WITH cte_end_dates AS (
    SELECT
        patient_id
        , encounter_class
        , event_date - interval '1 day' AS end_date
    FROM (
        SELECT
            patient_id
            , encounter_class
            , event_date
            , event_type
            , max(start_ordinal)
                OVER (
                    PARTITION BY
                        patient_id
                        , encounter_class
                    ORDER BY event_date, event_type ROWS UNBOUNDED PRECEDING
                )
            AS start_ordinal
            , row_number() OVER (
                PARTITION BY patient_id, encounter_class
                ORDER BY event_date, event_type
            ) AS overall_ord
        FROM (
            SELECT
                patient_id
                , encounter_class
                , encounter_start_datetime AS event_date
                , -1 AS event_type
                , row_number() OVER (
                    PARTITION BY patient_id, encounter_class
                    ORDER BY encounter_start_datetime, encounter_stop_datetime
                ) AS start_ordinal
            FROM {{ ref( 'stg_synthea__encounters') }}
            WHERE encounter_class = 'inpatient'
            UNION ALL
            SELECT
                patient_id
                , encounter_class
                , encounter_stop_datetime + interval '1 day' AS event_date
                , 1 AS event_type
                , NULL AS start_ordinal
            FROM {{ ref( 'stg_synthea__encounters') }}
            WHERE encounter_class = 'inpatient'
        ) AS rawdata
    ) AS e
    WHERE (2 * e.start_ordinal - e.overall_ord = 0)
)

, cte_visit_ends AS (
    SELECT
        min(v.encounter_id) AS encounter_id
        , v.patient_id
        , v.encounter_class
        , v.encounter_start_datetime AS visit_start_date
        , min(e.end_date) AS visit_end_date
    FROM {{ ref( 'stg_synthea__encounters') }} AS v
    INNER JOIN cte_end_dates AS e
        ON
            v.patient_id = e.patient_id
            AND v.encounter_class = e.encounter_class
            AND v.encounter_start_datetime <= e.end_date
    GROUP BY v.patient_id, v.encounter_class, v.encounter_start_datetime
)

SELECT
    t2.encounter_id
    , t2.patient_id
    , t2.encounter_class
    , t2.visit_start_date
    , t2.visit_end_date
FROM (
    SELECT
        encounter_id
        , patient_id
        , encounter_class
        , min(visit_start_date) AS visit_start_date
        , visit_end_date
    FROM cte_visit_ends
    GROUP BY encounter_id, patient_id, encounter_class, visit_end_date
) AS t2
