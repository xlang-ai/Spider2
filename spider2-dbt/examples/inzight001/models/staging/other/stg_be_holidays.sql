with src as (
    select * from {{ ref('be_holidays') }}
),

casts as (
    select
        Feestdag as holiday_name_nl,
        strptime(Datum, '%d %b %Y')::date as holiday_date
    from src
),

final as (
    select
        *
    from casts
    order by holiday_date asc
)

select * from final
