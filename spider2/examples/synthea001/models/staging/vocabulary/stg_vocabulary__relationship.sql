{% set column_names = 
    dbt_utils.get_filtered_columns_in_relation( source('vocabulary', 'relationship') ) 
%}


WITH cte_relationship_lower AS (

    SELECT
        {{ lowercase_columns(column_names) }}
    FROM {{ source('vocabulary','relationship') }}
)

SELECT *
FROM cte_relationship_lower
