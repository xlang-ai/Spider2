{% set column_names = 
    dbt_utils.get_filtered_columns_in_relation( source('vocabulary', 'drug_strength') ) 
%}


WITH cte_drug_strength_lower AS (

    SELECT
        {{ lowercase_columns(column_names) }}
    FROM {{ source('vocabulary','drug_strength') }}
)

SELECT *
FROM cte_drug_strength_lower
