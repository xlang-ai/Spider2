{% set column_names = 
    dbt_utils.get_filtered_columns_in_relation( source('synthea', 'payers') ) 
%}


WITH cte_payers_lower AS (

    SELECT
        {{ lowercase_columns(column_names) }}
    FROM {{ source('synthea','payers') }}
)

, cte_payers_rename AS (

    SELECT
        id AS payer_id
        , "name" AS payer_name
        , city AS payer_city
        , state_headquartered AS payer_state_headquartered
        , zip AS payer_zip
        , phone AS payer_phone
        , amount_covered AS payer_amount_covered
        , amount_uncovered AS payer_amount_uncovered
        , revenue AS payer_revenue
        , covered_encounters
        , uncovered_encounters
        , covered_procedures
        , uncovered_procedures
        , covered_immunizations
        , uncovered_immunizations
        , unique_customers
        , qols_avg
        , member_months AS payer_member_months
    FROM cte_payers_lower

)

SELECT *
FROM cte_payers_rename
