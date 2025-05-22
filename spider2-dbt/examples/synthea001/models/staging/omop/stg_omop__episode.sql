{% set column_names = 
    dbt_utils.get_filtered_columns_in_relation( source('omop', 'episode') ) 
%}


WITH cte_episode_lower AS (

    SELECT
        {{ lowercase_columns(column_names) }}
    FROM {{ source('omop','episode') }}
)

SELECT *
FROM cte_episode_lower
