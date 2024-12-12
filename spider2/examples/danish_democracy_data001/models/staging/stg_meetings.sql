with

source as (

    select * from {{ source('danish_parliament', 'raw_moede') }}
    qualify row_number() over (partition by id order by opdateringsdato desc) = 1

),

renamed as (
    select
        id as meeting_id,
        dagsordenurl as agenda_url,
        dato as meeting_date,
        lokale as meeting_room,
        nummer as meeting_number,
        offentlighedskode as public_code,
        opdateringsdato as meeting_updated_at,
        periodeid as meeting_period_id,
        "starttidsbemærkning" as meeting_start_time_note,
        statusid as meeting_status_id,
        titel as meeting_title,
        typeid as meeting_type_id,
        filename as file_name
    from source
)

select * from renamed
