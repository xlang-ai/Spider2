{% set column_names = 
    dbt_utils.get_filtered_columns_in_relation( source('omop', 'dose_era') ) 
%}


WITH cte_dose_era_lower AS (

    SELECT
        {{ lowercase_columns(column_names) }}
    FROM {{ source('omop','dose_era') }}
)

SELECT *
FROM cte_dose_era_lower
