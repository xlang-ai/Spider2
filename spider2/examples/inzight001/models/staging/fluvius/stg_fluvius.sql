with

src as (
    select *
    from {{ source('fluvius', 'verbruik') }}
),

final as (
    select
        "van datum"::date as from_date,
        "van tijdstip"::time as from_time,
        "tot datum"::date as to_date,
        "tot tijdstip"::time as to_time,
        lower(register) as register,
        replace(volume, ',', '.')::double as volume_in_kwh,
        validatiestatus as validation_status_txt
    from src
)

select * from final