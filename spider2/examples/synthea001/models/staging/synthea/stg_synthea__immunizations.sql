{% set column_names = 
    dbt_utils.get_filtered_columns_in_relation( source('synthea', 'immunizations') ) 
%}


WITH cte_immunizations_lower AS (

    SELECT
        {{ lowercase_columns(column_names) }}
    FROM {{ source('synthea','immunizations') }}
)

, cte_immunizations_rename AS (

    SELECT
        "date" AS immunization_date
        , patient AS patient_id
        , encounter AS encounter_id
        , code AS immunization_code
        , "description" AS immunization_description
        , base_cost AS immunization_base_cost
    FROM cte_immunizations_lower

)

SELECT *
FROM cte_immunizations_rename
