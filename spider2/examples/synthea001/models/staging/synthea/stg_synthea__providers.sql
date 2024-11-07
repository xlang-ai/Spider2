{% set column_names = 
    dbt_utils.get_filtered_columns_in_relation( source('synthea', 'providers') ) 
%}


WITH cte_providers_lower AS (

    SELECT
        {{ lowercase_columns(column_names) }}
    FROM {{ source('synthea','providers') }}
)

, cte_providers_rename AS (

    SELECT
        id AS provider_id
        , organization AS organization_id
        , "name" AS provider_name
        , gender AS provider_gender
        , speciality AS provider_specialty
        , "address" AS provider_address
        , city AS provider_city
        , "state" AS provider_state
        , zip AS provider_zip
        , lat AS provider_latitude
        , lon AS provider_longitude
        , utilization AS provider_utilization
    FROM cte_providers_lower

)

SELECT *
FROM cte_providers_rename
