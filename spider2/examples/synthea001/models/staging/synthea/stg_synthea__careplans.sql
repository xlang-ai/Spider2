{% set column_names = 
    dbt_utils.get_filtered_columns_in_relation( source('synthea', 'careplans') ) 
%}


WITH cte_careplans_lower AS (

    SELECT
        {{ lowercase_columns(column_names) }}
    FROM {{ source('synthea','careplans') }}
)

, cte_careplans_rename AS (

    SELECT
        id AS careplan_id
        , "start" AS careplan_start_date
        , "stop" AS careplan_stop_date
        , patient AS patient_id
        , encounter AS encounter_id
        , code AS careplan_code
        , "description" AS careplan_description
        , reasoncode AS careplan_reason_code
        , reasondescription AS careplan_reason_description
    FROM cte_careplans_lower

)

SELECT *
FROM cte_careplans_rename
