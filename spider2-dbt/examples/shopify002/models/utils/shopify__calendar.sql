{% set start_date = var('shopify__calendar_start_date', '2019-01-01') %}

{{ dbt_utils.date_spine(
    datepart="day",
    start_date="cast('" ~ start_date ~ "' as date)",
    end_date="current_date"
    )
}}