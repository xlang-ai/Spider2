with

source as (

    select * from {{ source('danish_parliament', 'raw_sagstrinsstatus') }}
    qualify row_number() over (partition by id order by opdateringsdato desc) = 1

),

renamed as (
    select
        id as case_step_status_id,
        status as case_step_status,
        opdateringsdato as case_step_status_updated_at,
        filename as file_name
    from source
)

select * from renamed
