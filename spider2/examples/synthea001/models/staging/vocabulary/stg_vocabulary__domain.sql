{% set column_names = 
    dbt_utils.get_filtered_columns_in_relation( source('vocabulary', 'domain') ) 
%}


WITH cte_domain_lower AS (

    SELECT
        {{ lowercase_columns(column_names) }}
    FROM {{ source('vocabulary','domain') }}
)

SELECT *
FROM cte_domain_lower
