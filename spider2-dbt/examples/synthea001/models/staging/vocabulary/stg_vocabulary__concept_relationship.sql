{% set column_names = 
    dbt_utils.get_filtered_columns_in_relation( source('vocabulary', 'concept_relationship') ) 
%}


WITH cte_concept_relationship_lower AS (

    SELECT
        {{ lowercase_columns(column_names) }}
    FROM {{ source('vocabulary','concept_relationship') }}
)

SELECT *
FROM cte_concept_relationship_lower
