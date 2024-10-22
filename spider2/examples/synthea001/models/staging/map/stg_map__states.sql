{% set column_names = 
    dbt_utils.get_filtered_columns_in_relation( source('map', 'states') ) 
%}


WITH cte_states_lower AS (

    SELECT
        {{ lowercase_columns(column_names) }}
    FROM {{ source('map','states') }}
)

SELECT *
FROM cte_states_lower
