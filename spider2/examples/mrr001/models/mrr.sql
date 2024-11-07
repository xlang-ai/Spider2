
with unioned as (

    select * from {{ ref('customer_revenue_by_month') }}

    union all

    select * from {{ ref('customer_churn_month') }}

),

lagged_values as (
    select
        *,
        coalesce(
            lag(is_active) over (partition by customer_id order by date_month),
            false
        ) as previous_month_is_active,
        coalesce(
            lag(mrr) over (partition by customer_id order by date_month),
            0
        ) as previous_month_mrr
    from unioned
),
