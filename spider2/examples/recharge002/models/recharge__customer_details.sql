with customers as (
    select *
    from {{ ref('int_recharge__customer_details') }} 

), enriched as (
    select 
        customers.*,
        case when subscriptions_active_count > 0 
            then true else false end as is_currently_subscribed,
        case when {{ dbt.datediff("first_charge_processed_at", dbt.current_timestamp_backcompat(), "day") }} <= 30
            then true else false end as is_new_customer,
        round(cast({{ dbt.datediff("first_charge_processed_at", dbt.current_timestamp_backcompat(), "day") }} / 30 as {{ dbt.type_numeric() }}), 2)
            as active_months
    from customers

), aggs as (
    select
        enriched.*,
        {% set agged_cols = ['orders', 'amount_ordered', 'one_time_purchases', 
            'amount_charged', 'amount_discounted', 'amount_taxed', 'net_spend'] %}
        {% for col in agged_cols %}
            round(cast({{- dbt_utils.safe_divide('total_' ~ col, 'active_months') }} as {{ dbt.type_numeric() }}), 2) 
                as {{col}}_monthly_average -- calculates average over no. active mos
            {{ ',' if not loop.last -}}
        {% endfor %}
    from enriched
)

select * 
from aggs