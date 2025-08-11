with

source as (

    select * from {{ source('danish_parliament', 'raw_sagstrinaktoer') }}
    qualify row_number() over (partition by id order by opdateringsdato desc) = 1

),

renamed as (
    select
        id as case_step_actor_id,
        sagstrinid as case_step_id,
        "aktørid" as actor_id,
        opdateringsdato as case_step_actor_updated_at,
        rolleid as role_id,
        filename as file_name
    from source
)

select * from renamed
