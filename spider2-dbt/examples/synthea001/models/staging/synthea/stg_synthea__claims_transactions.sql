{% set column_names = 
    dbt_utils.get_filtered_columns_in_relation( source('synthea', 'claims_transactions') ) 
%}


WITH cte_claims_transactions_lower AS (

    SELECT
        {{ lowercase_columns(column_names) }}
    FROM {{ source('synthea','claims_transactions') }}
)

, cte_claims_transactions_rename AS (

    SELECT
        id AS claim_transaction_id
        , claimid AS claim_id
        , chargeid AS charge_id
        , patientid AS patient_id
        , "type" AS transaction_type
        , amount AS transaction_amount
        , method AS transaction_method
        , fromdate AS transaction_from_date
        , todate AS transaction_to_date
        , placeofservice AS place_of_service
        , procedurecode AS procedure_code
        , modifier1 AS procedure_code_modifier_1
        , modifier2 AS procedure_code_modifier_2
        , diagnosisref1 AS claim_diagnosis_ref_1
        , diagnosisref2 AS claim_diagnosis_ref_2
        , diagnosisref3 AS claim_diagnosis_ref_3
        , diagnosisref4 AS claim_diagnosis_ref_4
        , units AS service_units
        , departmentid AS department_id
        , notes AS transaction_notes
        , unitamount AS per_unit_amount
        , transferoutid AS transfer_out_id
        , transfertype AS transfer_type
        , payments
        , adjustments
        , transfers
        , outstanding
        , appointmentid AS encounter_id
        , linenote AS claim_transaction_line_note
        , patientinsuranceid AS patient_insurance_id
        , feescheduleid AS fee_schedule_id
        , providerid AS provider_id
        , supervisingproviderid AS supervising_provider_id
    FROM cte_claims_transactions_lower

)

SELECT *
FROM cte_claims_transactions_rename
