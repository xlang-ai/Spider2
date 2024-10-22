{% set column_names = 
    dbt_utils.get_filtered_columns_in_relation( source('synthea', 'patients') ) 
%}


WITH cte_patients_lower AS (

    SELECT
        {{ lowercase_columns(column_names) }}
    FROM {{ source('synthea','patients') }}
)

, cte_patients_rename AS (

    SELECT
        id AS patient_id
        , birthdate AS birth_date
        , deathdate AS death_date
        , ssn
        , drivers AS drivers_license_number
        , passport AS passport_number
        , prefix AS patient_prefix
        , "first" AS patient_first_name
        , "last" AS patient_last_name
        , suffix AS patient_suffix
        , maiden AS maiden_name
        , marital AS marital_status
        , race
        , ethnicity
        , gender AS patient_gender
        , birthplace
        , "address" AS patient_address
        , city AS patient_city
        , "state" AS patient_state
        , county AS patient_county
        , zip AS patient_zip
        , lat AS patient_latitude
        , lon AS patient_longitude
        , healthcare_expenses
        , healthcare_coverage
    FROM cte_patients_lower

)

SELECT *
FROM cte_patients_rename
