with

source as (

    select * from {{ source('danish_parliament', 'raw_afstemningstype') }}
    qualify row_number() over (partition by id order by opdateringsdato desc) = 1

),

renamed as (
    select
        id as voting_type_id,
        opdateringsdato as voting_type_updated_at,
        type as voting_type,
        filename as file_name
    from source
)

select * from renamed
