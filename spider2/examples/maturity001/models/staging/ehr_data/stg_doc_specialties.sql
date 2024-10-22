with 

source as (
    select * from {{ source('ehr_data', 'doc_specialties') }}
),

renamed as (

    select 
        -- ids
        id as specialty_id,
        doc_id as doctor_id, 

        -- varchars
        category as specialty_category,
        specialty as specialty_name,

        -- dates
        created as created_at,
        _fivetran_synced_at as _fivetran_synced_at
    
    from source


)

select * from renamed