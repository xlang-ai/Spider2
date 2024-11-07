{% set column_names = 
    dbt_utils.get_filtered_columns_in_relation( source('synthea', 'observations') ) 
%}


WITH cte_observations_lower AS (

    SELECT
        {{ lowercase_columns(column_names) }}
    FROM {{ source('synthea','observations') }}
)

, cte_observations_rename AS (

    SELECT
        "date" AS observation_datetime
        , patient AS patient_id
        , encounter AS encounter_id
        , category AS observation_category
        , code AS observation_code
        , "description" AS observation_description
        , "value" AS observation_value
        , units AS observation_units
        , "type" AS observation_value_type
    FROM cte_observations_lower

)

SELECT *
FROM cte_observations_rename
