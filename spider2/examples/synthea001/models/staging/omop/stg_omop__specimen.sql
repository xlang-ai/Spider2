{% set column_names = 
    dbt_utils.get_filtered_columns_in_relation( source('omop', 'specimen') ) 
%}


WITH cte_specimen_lower AS (

    SELECT
        {{ lowercase_columns(column_names) }}
    FROM {{ source('omop','specimen') }}
)

SELECT *
FROM cte_specimen_lower
