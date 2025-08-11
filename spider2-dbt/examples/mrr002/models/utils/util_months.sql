{{ config(materialized='table') }}

with recursive date_spine as (
    -- Initialize the recursion with the start date
    select cast('2018-01-01' as date) as date_month
    union all
    -- Recursively add one month until the end date is reached
    select date_month + interval '1 month' as date_month
    from date_spine
    where date_month < date_trunc('month', current_date)
)

select
    date_month
from
    date_spine
