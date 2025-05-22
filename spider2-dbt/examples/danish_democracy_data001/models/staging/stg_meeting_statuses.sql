with

source as (

    select * from {{ source('danish_parliament', 'raw_moede_status') }}
    qualify row_number() over (partition by id order by opdateringsdato desc) = 1

),

renamed as (
    select
        id as meeting_status_id,
        status as meeting_status,
        opdateringsdato as meeting_status_updated_at,
        filename as file_name
    from source
)

select * from renamed
