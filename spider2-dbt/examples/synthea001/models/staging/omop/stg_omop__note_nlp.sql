{% set column_names = 
    dbt_utils.get_filtered_columns_in_relation( source('omop', 'note_nlp') ) 
%}


WITH cte_note_nlp_lower AS (

    SELECT
        {{ lowercase_columns(column_names) }}
    FROM {{ source('omop','note_nlp') }}
)

SELECT *
FROM cte_note_nlp_lower
