SELECT
    encounter_id
    , visit_occurrence_id_new
FROM (
    SELECT
        *
        , row_number() OVER (PARTITION BY encounter_id ORDER BY priority) AS rn
    FROM (
        SELECT
            *
            , CASE
                WHEN encounter_class IN ('emergency', 'urgent')
                    THEN (
                        CASE
                            WHEN
                                visit_type = 'inpatient'
                                AND visit_occurrence_id_new IS NOT null
                                THEN 1
                            WHEN
                                visit_type IN ('emergency', 'urgent')
                                AND visit_occurrence_id_new IS NOT null
                                THEN 2
                            ELSE 99
                        END
                    )
                WHEN encounter_class IN ('ambulatory', 'wellness', 'outpatient')
                    THEN (
                        CASE
                            WHEN
                                visit_type = 'inpatient'
                                AND visit_occurrence_id_new IS NOT null
                                THEN 1
                            WHEN
                                visit_type IN (
                                    'ambulatory', 'wellness', 'outpatient'
                                )
                                AND visit_occurrence_id_new IS NOT null
                                THEN 2
                            ELSE 99
                        END
                    )
                WHEN
                    encounter_class = 'inpatient'
                    AND visit_type = 'inpatient'
                    AND visit_occurrence_id_new IS NOT null
                    THEN 1
                ELSE 99
            END AS priority
        FROM {{ ref('int__assign_all_visit_ids') }}
    ) AS t1
) AS t2
WHERE rn = 1
