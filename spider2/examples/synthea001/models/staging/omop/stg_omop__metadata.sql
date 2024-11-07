{% set column_names = 
    dbt_utils.get_filtered_columns_in_relation( source('omop', 'metadata') ) 
%}


WITH cte_metadata_lower AS (

    SELECT
        {{ lowercase_columns(column_names) }}
    FROM {{ source('omop','metadata') }}
)

SELECT *
FROM cte_metadata_lower
