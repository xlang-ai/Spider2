with

source as (

    select * from {{ source('danish_parliament', 'raw_stemme_type') }}
    qualify row_number() over (partition by id order by opdateringsdato desc) = 1

),

renamed as (
    select
        id as individual_voting_type_id,
        type as individual_voting_type,
        filename as file_name
    from source
)

select * from renamed
