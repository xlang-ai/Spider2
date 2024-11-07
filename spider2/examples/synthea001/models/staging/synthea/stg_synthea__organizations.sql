{% set column_names = 
    dbt_utils.get_filtered_columns_in_relation( source('synthea', 'organizations') ) 
%}


WITH cte_organizations_lower AS (

    SELECT
        {{ lowercase_columns(column_names) }}
    FROM {{ source('synthea','organizations') }}
)

, cte_organizations_rename AS (

    SELECT
        id AS organization_id
        , name AS organization_name
        , address AS organization_address
        , city AS organization_city
        , state AS organization_state
        , zip AS organization_zip
        , lat AS organization_latitude
        , lon AS organization_longitude
        , phone AS organization_phone
        , revenue AS organization_revenue
        , utilization AS organization_utilization
    FROM cte_organizations_lower

)

SELECT *
FROM cte_organizations_rename
