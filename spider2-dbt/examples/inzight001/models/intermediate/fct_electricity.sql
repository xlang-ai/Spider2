with

fluvius as (
    select *
    from {{ ref('stg_fluvius') }}
),

with_timestamps as (
    select
        make_timestamp(year(from_date), month(from_date), day(from_date), hour(from_time), minute(from_time), second(from_time)) as from_timestamp,
        make_timestamp(year(to_date), month(to_date), day(to_date), hour(to_time), minute(to_time), second(to_time)) as to_timestamp,
        register,
        volume_in_kwh,
        validation_status_txt
    from fluvius
),

validation_status as (
    select
        from_timestamp,
        to_timestamp,
        register,
        volume_in_kwh,
        case
            when validation_status_txt = 'Gevalideerd' then TRUE
            else FALSE
        end as validated
    from with_timestamps
),

tariff as (
    select
        from_timestamp,
        to_timestamp,
        case when contains(register, 'nacht') then 'offpeak'
             when contains(register, 'dag') then 'peak'
        end as tariff,
        case when contains(register, 'afname') then volume_in_kwh
             else 0.0
        end as usage,
        case when contains(register, 'injectie') then volume_in_kwh
             else 0.0
        end as injection,
        validated
    from validation_status
),

final as (
    select
        from_timestamp,
        to_timestamp,
        tariff,
        usage,
        injection,
        validated
    from tariff
    order by from_timestamp asc, to_timestamp asc, injection asc, usage asc
)

select * from final