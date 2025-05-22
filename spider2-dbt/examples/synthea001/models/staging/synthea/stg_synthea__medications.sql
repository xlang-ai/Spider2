{% set column_names = 
    dbt_utils.get_filtered_columns_in_relation( source('synthea', 'medications') ) 
%}


WITH cte_medications_lower AS (

    SELECT
        {{ lowercase_columns(column_names) }}
    FROM {{ source('synthea','medications') }}
)

, cte_medications_rename AS (

    SELECT
        "start" AS medication_start_datetime
        , "stop" AS medication_stop_datetime
        , patient AS patient_id
        , payer AS payer_id
        , encounter AS encounter_id
        , code AS medication_code
        , "description" AS medication_description
        , base_cost AS medication_base_cost
        , payer_coverage AS medication_payer_coverage
        , dispenses
        , totalcost AS medication_total_cost
        , reasoncode AS medication_reason_code
        , reasondescription AS medication_reason_description
    FROM cte_medications_lower

)

SELECT *
FROM cte_medications_rename
