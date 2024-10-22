with recursive date_cte as (
    select '2000-01-01'::date as date
    union all
    select date + INTERVAL 1 DAY
    from date_cte
    where date <= '2030-01-01'
)

select
    date::date as date,
    strftime('%Y%m%d', date)::int as date_id,
    extract(year from date)::int as year,
    extract(quarter from date)::int as quarter,
    extract(month from date)::int as month,
    extract(week from date)::int as week,
    extract(isodow from date)::int as dow,
    strftime('%A', date) as week_day
from date_cte
