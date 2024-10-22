SELECT
    *
    , row_number() OVER (ORDER BY patient_id) AS visit_occurrence_id
FROM
    (
        SELECT * FROM {{ ref('int__ip_visits') }}
        UNION ALL
        SELECT * FROM {{ ref('int__er_visits') }}
        UNION ALL
        SELECT * FROM {{ ref('int__op_visits') }}
    ) AS t1
