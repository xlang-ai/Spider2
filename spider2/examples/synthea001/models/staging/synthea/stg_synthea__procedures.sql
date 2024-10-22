{% set column_names = 
    dbt_utils.get_filtered_columns_in_relation( source('synthea', 'procedures') ) 
%}


WITH cte_procedures_lower AS (

    SELECT
        {{ lowercase_columns(column_names) }}
    FROM {{ source('synthea','procedures') }}
)

, cte_procedures_rename AS (

    SELECT
        "start" AS procedure_start_datetime
        , "stop" AS procedure_stop_datetime
        , patient AS patient_id
        , encounter AS encounter_id
        , code AS procedure_code
        , "description" AS procedure_description
        , base_cost AS procedure_base_cost
        , reasoncode AS procedure_reason_code
        , reasondescription AS procedure_reason_description
    FROM cte_procedures_lower

)

SELECT *
FROM cte_procedures_rename
