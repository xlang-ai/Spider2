with 

source as (
    select * from {{ source('ehr_data', 'patients') }}
),

renamed as (

    select 
        -- ids
        id as patient_id, 
        prac_id as practice_id,

        -- varchars
        name_f as first_name,
        name_l as last_name,
        first_name || ' ' ||  last_name as patient_name,
        bill_to as billing_address,
        zip as zip_code,
        state as state,
        country as country,
        email as email,

        -- booleans
        diabetes as is_diabetic,
        email like '%@test-patient.com' as is_test,

        -- dates
        dob as date_of_birth,
        created as created_at,
        last_login as last_logged_in_at,
        _fivetran_synced_at as _fivetran_synced_at
    
    from source 

    where not(is_test)


)

select * from renamed