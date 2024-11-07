with source as (

    select * from {{ source('tickit_external', 'date') }}

),

renamed as (

    select
        dateid as date_id,
        caldate as cal_date,
        day,
        month,
        year,
        week,
        qtr,
        holiday
    from
        source
    where
        date_id IS NOT NULL
    order by
        date_id

)

select * from renamed