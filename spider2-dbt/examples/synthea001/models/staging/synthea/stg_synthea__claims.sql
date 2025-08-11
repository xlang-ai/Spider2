{% set column_names = 
    dbt_utils.get_filtered_columns_in_relation( source('synthea', 'claims') ) 
%}


WITH cte_claims_lower AS (

    SELECT
        {{ lowercase_columns(column_names) }}
    FROM {{ source('synthea','claims') }}
)

, cte_claims_rename AS (

    SELECT
        id AS claim_id
        , patientid AS patient_id
        , providerid AS provider_id
        , CASE
            WHEN primarypatientinsuranceid = '0' THEN NULL
            ELSE primarypatientinsuranceid
        END AS primary_patient_insurance_id
        , CASE
            WHEN secondarypatientinsuranceid = '0' THEN NULL
            ELSE secondarypatientinsuranceid
        END AS secondary_patient_insurance_id
        , departmentid AS department_id
        , patientdepartmentid AS patient_department_id
        , diagnosis1 AS diagnosis_1
        , diagnosis2 AS diagnosis_2
        , diagnosis3 AS diagnosis_3
        , diagnosis4 AS diagnosis_4
        , diagnosis5 AS diagnosis_5
        , diagnosis6 AS diagnosis_6
        , diagnosis7 AS diagnosis_7
        , diagnosis8 AS diagnosis_8
        , referringproviderid AS referring_provider_id
        , appointmentid AS encounter_id
        , currentillnessdate AS current_illness_date
        , servicedate AS service_date
        , supervisingproviderid AS supervising_provider_id
        , status1 AS claim_status_1
        , status2 AS claim_status_2
        , statusp AS claim_status_patient
        , outstanding1 AS outstanding_1
        , outstanding2 AS outstanding_2
        , outstandingp AS outstanding_patient
        , lastbilleddate1 AS last_billed_date_1
        , lastbilleddate2 AS last_billed_date_2
        , lastbilleddatep AS last_billed_date_patient
        , healthcareclaimtypeid1 AS claim_type_id_1
        , healthcareclaimtypeid2 AS claim_type_id_2
    FROM cte_claims_lower

)

SELECT *
FROM cte_claims_rename
