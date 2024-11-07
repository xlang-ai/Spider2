{% set column_names = 
    dbt_utils.get_filtered_columns_in_relation( source('vocabulary', 'concept_synonym') ) 
%}


WITH cte_concept_synonym_lower AS (

    SELECT
        {{ lowercase_columns(column_names) }}
    FROM {{ source('vocabulary','concept_synonym') }}
)

SELECT *
FROM cte_concept_synonym_lower
