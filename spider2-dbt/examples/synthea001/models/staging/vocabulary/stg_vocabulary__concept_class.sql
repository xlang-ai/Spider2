{% set column_names = 
    dbt_utils.get_filtered_columns_in_relation( source('vocabulary', 'concept_class') ) 
%}


WITH cte_concept_class_lower AS (

    SELECT
        {{ lowercase_columns(column_names) }}
    FROM {{ source('vocabulary','concept_class') }}
)

SELECT *
FROM cte_concept_class_lower
