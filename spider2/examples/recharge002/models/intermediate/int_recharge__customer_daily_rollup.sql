with calendar as (
    select *
    from {{ ref('int_recharge__calendar_spine') }}

), customers as (
    select 
        customer_id, 
        customer_created_at
    from {{ ref('recharge__customer_details') }}

), customers_dates as (
    select 
        customers.customer_id,
        calendar.date_day,
        cast({{ dbt.date_trunc('week', 'calendar.date_day') }} as date) as date_week,
        cast({{ dbt.date_trunc('month', 'calendar.date_day') }} as date) as date_month,
        cast({{ dbt.date_trunc('year', 'calendar.date_day') }} as date) as date_year
    from calendar
    cross join customers
    where cast({{ dbt.date_trunc('day', 'customers.customer_created_at') }} as date) <= calendar.date_day
)

select *
from customers_dates