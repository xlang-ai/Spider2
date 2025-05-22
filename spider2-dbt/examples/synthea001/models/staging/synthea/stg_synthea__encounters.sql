{% set column_names = 
    dbt_utils.get_filtered_columns_in_relation( source('synthea', 'encounters') ) 
%}


WITH cte_encounters_lower AS (

    SELECT
        {{ lowercase_columns(column_names) }}
    FROM {{ source('synthea','encounters') }}
)

, cte_encounters_rename AS (

    SELECT
        id AS encounter_id
        , start AS encounter_start_datetime
        , stop AS encounter_stop_datetime
        , patient AS patient_id
        , organization AS organization_id
        , provider AS provider_id
        , payer AS payer_id
        , encounterclass AS encounter_class
        , code AS encounter_code
        , description AS encounter_description
        , base_encounter_cost
        , total_claim_cost AS total_encounter_cost
        , payer_coverage AS encounter_payer_coverage
        , reasoncode AS encounter_reason_code
        , reasondescription AS encounter_reason_description
    FROM cte_encounters_lower

)

SELECT *
FROM cte_encounters_rename
