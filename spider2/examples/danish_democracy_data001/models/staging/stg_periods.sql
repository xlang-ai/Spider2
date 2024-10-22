with

source as (

    select * from {{ source('danish_parliament', 'raw_periode') }}
    qualify row_number() over (partition by id order by opdateringsdato desc) = 1

),

renamed as (
    select
        id as period_id,
        startdato as period_start_date,
        slutdato as period_end_date,
        type as period_type,
        kode as period_code,
        titel as period_title,
        opdateringsdato as period_updated_at,
        filename as file_name
    from source
)

select * from renamed
