with

source as (

    select * from {{ source('danish_parliament', 'raw_moede_type') }}
    qualify row_number() over (partition by id order by opdateringsdato desc) = 1

),

renamed as (
    select
        id as meeting_type_id,
        type as meeting_type,
        opdateringsdato as meeting_type_updated_at,
        filename as file_name
    from source
)

select * from renamed
