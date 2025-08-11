{% set column_names = 
    dbt_utils.get_filtered_columns_in_relation( source('synthea', 'conditions') ) 
%}


WITH cte_conditions_lower AS (

    SELECT
        {{ lowercase_columns(column_names) }}
    FROM {{ source('synthea','conditions') }}
)

, cte_conditions_rename AS (

    SELECT
        "start" AS condition_start_date
        , "stop" AS condition_stop_date
        , patient AS patient_id
        , encounter AS encounter_id
        , code AS condition_code
        , "description" AS condition_description
    FROM cte_conditions_lower

)

SELECT *
FROM cte_conditions_rename
