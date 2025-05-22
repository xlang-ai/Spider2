{% set column_names = 
    dbt_utils.get_filtered_columns_in_relation( source('synthea', 'supplies') ) 
%}


WITH cte_supplies_lower AS (

    SELECT
        {{ lowercase_columns(column_names) }}
    FROM {{ source('synthea','supplies') }}
)

, cte_supplies_rename AS (

    SELECT
        "date" AS supply_date
        , patient AS patient_id
        , encounter AS encounter_id
        , code AS supply_code
        , "description" AS supply_description
        , quantity AS supply_quantity
    FROM cte_supplies_lower

)

SELECT *
FROM cte_supplies_rename
