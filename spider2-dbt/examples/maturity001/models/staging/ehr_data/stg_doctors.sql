with 

source as (
    select * from {{ source('ehr_data', 'doctors') }}
),

renamed as (

    select 
        -- ids
        id as doctor_id, 
        npi as npi,
        prac_id as practice_id,

        -- varchars
        name_f as first_name,
        name_l as last_name,
        name as doctor_name,
        bill_to as billing_address,
        zip as zip_code,
        state as state,
        country as country,

        -- dates
        created as created_at,
        last_login as last_logged_in_at,
        _fivetran_synced_at as _fivetran_synced_at
    
    from source


)

select * from renamed