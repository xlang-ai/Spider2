{% set column_names = 
    dbt_utils.get_filtered_columns_in_relation( source('vocabulary', 'vocabulary') ) 
%}


WITH cte_vocabulary_lower AS (

    SELECT
        {{ lowercase_columns(column_names) }}
    FROM {{ source('vocabulary','vocabulary') }}
)

SELECT *
FROM cte_vocabulary_lower
