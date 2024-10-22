{% set column_names = 
    dbt_utils.get_filtered_columns_in_relation( source('vocabulary', 'source_to_concept_map') ) 
%}


WITH cte_source_to_concept_map_lower AS (

    SELECT
        {{ lowercase_columns(column_names) }}
    FROM {{ source('vocabulary','source_to_concept_map') }}
)

SELECT *
FROM cte_source_to_concept_map_lower
