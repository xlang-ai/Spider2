{% set column_names = 
    dbt_utils.get_filtered_columns_in_relation( source('omop', 'fact_relationship') ) 
%}


WITH cte_fact_relationship_lower AS (

    SELECT
        {{ lowercase_columns(column_names) }}
    FROM {{ source('omop','fact_relationship') }}
)

SELECT *
FROM cte_fact_relationship_lower
