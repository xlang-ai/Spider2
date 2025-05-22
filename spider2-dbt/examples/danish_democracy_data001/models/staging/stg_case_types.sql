with

source as (

    select * from {{ source('danish_parliament', 'raw_sagstype') }}
    qualify row_number() over (partition by id order by opdateringsdato desc) = 1

),

renamed as (
    select
        id as case_type_id,
        type as case_type,
        opdateringsdato as case_type_updated_at,
        filename as file_name
    from source
)

select * from renamed
