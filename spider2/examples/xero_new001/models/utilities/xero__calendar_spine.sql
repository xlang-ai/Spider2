with spine as (

    {{ 
        dbt_utils.date_spine(
            datepart="month",
            start_date="cast('2019-01-01' as date)",
            end_date=dbt.dateadd(datepart='month', interval=1, from_date_or_timestamp="current_date")
        )
    }}

), cleaned as (

    select cast(date_month as date) as date_month
    from spine

)

select *
from cleaned