{{
    config(
        materialized = 'table',
    )
}}

with days as (

    {{
        dbt.date_spine(
            'day',
            "strptime('01/01/2000', '%m/%d/%Y')",
            "strptime('01/01/2027', '%m/%d/%Y')"
        )
    }}

),

final as (
    select cast(date_day as date) as date_day
    from days
)

select * from final
