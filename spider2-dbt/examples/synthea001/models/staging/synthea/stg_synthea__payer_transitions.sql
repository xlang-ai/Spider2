{% set column_names = 
    dbt_utils.get_filtered_columns_in_relation( source('synthea', 'payer_transitions') ) 
%}


WITH cte_payer_transitions_lower AS (

    SELECT
        {{ lowercase_columns(column_names) }}
    FROM {{ source('synthea','payer_transitions') }}
)

, cte_payer_transitions_rename AS (

    SELECT
        patient AS patient_id
        , memberid AS member_id
        , start_year AS coverage_start_datetime
        , end_year AS coverage_end_datetime
        , payer AS payer_id
        , secondary_payer AS secondary_payer_id
        , "ownership" AS plan_owner_relationship
        , ownername AS plan_owner_name
    FROM cte_payer_transitions_lower

)

SELECT *
FROM cte_payer_transitions_rename
